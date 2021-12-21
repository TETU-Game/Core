require "../components"

class EconomicProductionSystem
  include Entitas::Systems::ExecuteSystem

  def initialize(@context : GameContext); end

  def execute
    group = @context.get_group Entitas::Matcher.all_of Named, Population
    group.entities.each do |e|
      STDERR.puts "this named populated entity is #{e.named.to_s} and has #{e.population.to_s} pop"
    end
  end
end
