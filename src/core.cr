require "entitas"

require "./components"

class GalaxyInitializerSystem
  include Entitas::Systems::InitializeSystem

  def initialize(@context : GameContext); end

  def init
    10.times do |i|
      planet = @context
        .create_entity
      Named.generate_planet planet
      Population.generate planet
    end
    group = @context.get_group Entitas::Matcher.all_of Named, Population
    STDERR.puts "init #{group.entities.size} planets"
  end
end

class EconomicProductionSystem
  include Entitas::Systems::ExecuteSystem

  def initialize(@context : GameContext); end

  def execute
    group = @context.get_group Entitas::Matcher.all_of Named, Population
    group.entities.each do |e|
      STDERR.puts "this entity is #{e.named.name} has #{e.population.amount} pop"
    end
  end
end

class EconomicSystems < Entitas::Feature
  def initialize(contexts : Contexts)
    @name = "Economic System"
    ctx = contexts.game
    add ::EconomicProductionSystem.new(ctx)
    add ::GalaxyInitializerSystem.new(ctx)
  end
end

class HelloWorld
  getter systems : Entitas::Systems = Entitas::Systems.new

  def start
    # get a reference to the contexts
    contexts = Contexts.shared_instance

    # create the systems by creating individual features
    @systems = Entitas::Feature.new("systems")
               .add(EconomicSystems.new(contexts))
    @systems.init
  end

  def update
    # call execute on all the ExecuteSystems and
    # ReactiveSystems that were triggered last frame
    @systems.execute

    # call cleanup on all the CleanupSystems
    @systems.cleanup
  end
end

hw = HelloWorld.new
hw.start

10.times do |i|
  puts "Tick #{i}"
  Fiber.yield
  hw.update
end
