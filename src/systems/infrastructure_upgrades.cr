require "../components"

class InfrastructureUpgradesSystem
  include Entitas::Systems::ExecuteSystem

  def initialize(@context : GameContext); end

  def execute
    producer = @context.get_group Entitas::Matcher.all_of Resources, InfrastructureUpgrades
    producer.entities.each do |e|
      # pay the cost
      puts "e.infrastructure_upgrades.upgrades = #{e.infrastructure_upgrades.upgrades.size}"
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
    puts "pay_upgrade: #{resources.to_s} #{upgrade.to_s}"
    current_costs = upgrade.current_tick == 0 ? upgrade.costs_start : upgrade.costs_by_tick
    pay_upgrade_tick(resources, upgrade, current_costs)
  end

  def pay_upgrade_tick(resources : Resources, upgrade : InfrastructureUpgrade, costs : InfrastructureUpgrade::Costs)
    if costs.all? { |res, amount| resources.stores[res].amount >= amount }
      # pay the upgrade
      costs.all? { |res, amount| resources.stores[res].amount -= amount }
      upgrade.current_tick += 1
      puts "paid tick upgrade"
    else
      # if we can't pay the upgrade, we will "loose" one tick due to maintenance
      puts "cannot pay upgrade"
      upgrade.end_tick += 1
    end

    if upgrade.current_tick >= upgrade.end_tick
      upgrade
      upgrade.finish!
    end
    # don't forget to clean up after this
  end

  def apply_upgrade(resources : Resources, upgrade : InfrastructureUpgrade)
    puts "apply_upgrade: #{resources.to_s} #{upgrade.to_s}"
    infra_id = upgrade.id
    infra = InfrastructuresFileLoader.all[infra_id]

    local_infra = (resources.infras[upgrade.id] ||= Resources::Infra.new(id: infra_id, tier: 0))

    tier = (local_infra.tier += 1)
    infra.prods.each do |res, curve|
      resources.prods[res] ||= 0.0
      resources.prods[res] += curve.execute(tier)
    end
    infra.consumes.each do |res, curve|
      pp resources if !resources.consumes?
      resources.consumes[res] ||= 0.0
      resources.consumes[res] += curve.execute(tier)
    end
    infra.stores.each do |res, curve|
      resources.stores[res] ||= Resources::Store.new(amount: 0.0, max: 0.0)
      resources.stores[res].max += curve.execute(tier)
    end
  end

end
