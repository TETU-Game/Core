require "entitas"

module TETU
  MAX_X = 800
  MAX_Y = 600

  GENERATED_SYSTEMS_AMOUNT = 2
  GENERATED_PLANET_POPULATED_PROBA = 0.9
  MAX_GENERATED_BODIES_BY_SYSTEM_AMOUNT = 5
  MAX_GENERATED_MOON_BY_BODY_AMOUNT = 1
end

require "./components"
require "./systems/*"

class EconomicSystems < Entitas::Feature
  def initialize(contexts : Contexts)
    @name = "Economic System"
    ctx = contexts.game
    add ::EconomicProductionSystem.new(ctx)
    add ::GalaxyInitializerSystem.new(ctx)
    add ::MainUiSystem.new(ctx)
    add ::EconomicUpgradesSystem.new(ctx)
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


require "./gui/*"

hw = HelloWorld.new
hw.start

i = 0u64
loop do
  i += 1
  puts "Tic #{i}"
  Fiber.yield
  hw.update
end