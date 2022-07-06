require "../components"

class TETU::InfrastructureUpgradesSystem
  include Entitas::Systems::ExecuteSystem

  def initialize(@context : GameContext); end

  def execute
    producer = @context.get_group Entitas::Matcher.all_of Resources, InfrastructureUpgrades
    producer.entities.each do |e|
      # pay the cost
      # Log.debug { "e.infrastructure_upgrades.upgrades = #{e.infrastructure_upgrades.upgrades.size}" }
      e.infrastructure_upgrades.upgrades.reject! do |upgrade|
        pay_upgrade(e.resources, upgrade)
        if upgrade.finished?
          apply_upgrade(e.resources, upgrade)
          true
        else
          false
        end
      end
    end
  end

  def pay_upgrade(resources : Resources, upgrade : InfrastructureUpgrade)
    Log.debug { "pay_upgrade: #{resources.to_s} #{upgrade.to_s}" }
    current_costs = upgrade.current_tick == 0 ? upgrade.costs_start : upgrade.costs_by_tick
    pay_upgrade_tick(resources, upgrade, current_costs)
  end

  def pay_upgrade_tick(resources : Resources, upgrade : InfrastructureUpgrade, costs : InfrastructureUpgrade::Costs)
    if costs.all? { |res, amount| resources.stores[res].amount >= amount }
      # pay the upgrade with local store
      costs.all? { |res, amount| resources.stores[res].amount -= amount }
      upgrade.current_tick += 1
      Log.debug { "paid tick upgrade" }
    else
      # if we can't pay the upgrade, we will "loose" one tick due to maintenance
      Log.debug { "cannot pay upgrade" }
      upgrade.end_tick += 1
    end

    if upgrade.current_tick >= upgrade.end_tick
      upgrade
      upgrade.finish!
    end
    # don't forget to clean up after this
  end

  def apply_upgrade(resources : Resources, upgrade : InfrastructureUpgrade)
    Log.debug { "apply_upgrade: #{resources.to_s} #{upgrade.to_s}" }
    infra_id = upgrade.id
    infra = Helpers::InfrastructuresFileLoader.all[infra_id]

    local_infra = (resources.infras[upgrade.id] ||= Resources::Infra.new(id: infra_id, tier: 0, stores: resources.stores))

    tier = (local_infra.tier += 1)
    infra.prods.each do |res, curve|
      local_infra.prods[res] ||= 0.0
      local_infra.prods[res] += curve.execute(tier)
    end
    infra.consumes.each do |res, curve|
      local_infra.consumes[res] ||= 0.0
      local_infra.consumes[res] += curve.execute(tier)
    end
    infra.wastes.each do |res, curve|
      local_infra.wastes[res] ||= 0.0
      local_infra.wastes[res] += curve.execute(tier)
    end
    infra.stores.each do |res, curve|
      local_infra.stores[res] ||= Resources::Store.new(amount: 0.0, max: 0.0)
      local_infra.stores[res].max += curve.execute(tier)
    end
  end

end
