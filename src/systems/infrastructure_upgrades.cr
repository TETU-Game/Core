require "../components"

class TETU::InfrastructureUpgradesSystem
  include Entitas::Systems::ExecuteSystem
  spoved_logger level: :info, io: STDOUT, bind: true

  def initialize(@contexts : Contexts); end

  def execute
    producer = @contexts.game.get_group Entitas::Matcher.all_of Resources, InfrastructureUpgrades, ManpowerAllocation
    producer.entities.each do |e|
      # pay the cost
      # logger.debug { "e.infrastructure_upgrades.upgrades = #{e.infrastructure_upgrades.upgrades.size}" }
      e.infrastructure_upgrades.upgrades.reject! do |upgrade|
        pay_upgrade(e.resources, upgrade)
        if upgrade.finished?
          apply_upgrade(e, upgrade)
          true
        else
          false
        end
      end
    end
  end

  def apply_upgrade(entity : GameEntity, upgrade : InfrastructureUpgrade)
    resources = entity.resources
    logger.debug { "apply_upgrade: #{resources.to_s} #{upgrade.to_s}" }
    infra_id = upgrade.id
    infra = Helpers::InfrastructuresFileLoader.all[infra_id]

    local_infra = (resources.infras[upgrade.id] ||= Resources::Infra.new(id: infra_id, tier: 0, stores: resources.stores))

    tier = local_infra.tier
    next_tier = tier + 1
    local_infra.tier = next_tier
    # TODO: +curve.execute(tier + 1) - curve.execute(tier)
    infra.prods.each do |res, curve|
      local_infra.prods[res] ||= 0.0
      local_infra.prods[res] += curve.execute(next_tier) - curve.execute(tier)
    end
    infra.consumes.each do |res, curve|
      local_infra.consumes[res] ||= 0.0
      local_infra.consumes[res] += curve.execute(next_tier) - curve.execute(tier)
    end
    infra.wastes.each do |res, curve|
      local_infra.wastes[res] ||= 0.0
      local_infra.wastes[res] += curve.execute(next_tier) - curve.execute(tier)
    end
    infra.stores.each do |res, curve|
      local_infra.stores[res] ||= Resources::Store.new(amount: 0.0, max: 0.0)
      local_infra.stores[res].max += curve.execute(next_tier) - curve.execute(tier)
    end
    local_infra.manpower.min = infra.manpower.min.execute(next_tier)
    local_infra.manpower.optimal = infra.manpower.optimal.execute(next_tier)
    local_infra.manpower.max = infra.manpower.max.execute(next_tier)

    manpower_allocation = entity.manpower_allocation
    if !manpower_allocation.fixed.key_for?(infra_id)
      manpower_allocation.fixed[infra_id] = false
      manpower_allocation.ratio[infra_id] = 0.0
      if manpower_allocation.available >= local_infra.manpower.optimal
        manpower_allocation.absolute[infra_id] = local_infra.manpower.optimal
        manpower_allocation.available -= local_infra.manpower.optimal
      else
        manpower_allocation.absolute[infra_id] = manpower_allocation.available
        manpower_allocation.available = 0
      end
    end
  end

  def pay_upgrade(resources : Resources, upgrade : InfrastructureUpgrade)
    logger.debug { "pay_upgrade: #{resources.to_s} #{upgrade.to_s}" }
    current_costs = upgrade.current_tick == 0 ? upgrade.costs_start : upgrade.costs_by_tick
    pay_upgrade_tick(resources, upgrade, current_costs)
  end

  def pay_upgrade_tick(resources : Resources, upgrade : InfrastructureUpgrade, costs : InfrastructureUpgrade::Costs)
    if costs.all? { |res, amount| resources.stores[res].amount >= amount }
      # pay the upgrade with local store
      costs.all? { |res, amount| resources.stores[res].amount -= amount }
      upgrade.current_tick += 1
      logger.debug { "paid tick upgrade" }
    else
      # if we can't pay the upgrade, we will "loose" one tick due to maintenance
      logger.debug { "cannot pay upgrade" }
      upgrade.end_tick += 1
    end

    if upgrade.current_tick >= upgrade.end_tick
      upgrade
      upgrade.finish!
    end
    # don't forget to clean up after this
  end
end
