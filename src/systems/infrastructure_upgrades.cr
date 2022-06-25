require "../components"

class InfrastuctureUpgradesSystem
  include Entitas::Systems::ExecuteSystem

  def initialize(@context : GameContext); end

  def execute
    producer = @context.get_group Entitas::Matcher.all_of Resources, InfrastructureUpgrades
    producer.entities.each do |e|
      # pay the cost
      e.infrastructure_upgrades.upgrades.each do |upgrade|
        pay_upgrade(e.resources, upgrade)
      end

      # apply finished upgrade & remove from upgrade TBFinished
      e.infrastructure_upgrades.upgrades.reject! do |upgrade|
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

  def pay_upgrade_tick(resources : Resources, upgrade : InfrastructureUpgrade, costs : Symbol)
    if costs.all? { |res, amount| resources.storages[res] >= amount }
      # pay the upgrade
      costs.all? { |res, amount| resources.add(res, -amount) }
      upgrade.current_tick += 1
    else
      # if we can't pay the upgrade, we will "loose" one tick due to maintenance
      upgrade.end_tick += 1
    end

    if upgrade.current_tick >= upgrade.end_tick
      upgrade
      upgrade.finish!
    end
    # don't forget to clean up after this
  end

  def apply_upgrade(resources : Resources, upgrade : InfrastructureUpgrade)
    infra_id = upgrade.id
    infra = InfrastructuresFileLoader.all[infra_id]

    tier = (resources.infras[upgrade.id].tier += 1)
    infra.prods.each do |res, curve|
      res.prods[res] += curve.execute(tier)
    end
  end

end
