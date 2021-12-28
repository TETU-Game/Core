require "../components"

class EconomicUpgradesSystem
  include Entitas::Systems::ExecuteSystem

  def initialize(@context : GameContext); end

  def execute
    producer = @context.get_group Entitas::Matcher.all_of Resources, ResourcesUpgrades
    producer.entities.each do |e|
      e.resources_upgrades.upgrades.each do |upgrade|
        puts "receive an upgrade to execute: #{upgrade}"
        e.resources.upgrade(upgrade)
      end
      e.resources_upgrades.upgrades.clear
    end
  end
end
