require "entitas"

module TETU
end

require "./core/*"

module TETU
  CONF = TETU::Configuration.instance
  
  MAX_X = CONF["max_x"].as_i
  MAX_Y = CONF["max_y"].as_i

  GALAXY_CONF = TETU::CONF["galaxy"]
  UI_CONF = TETU::CONF["ui"]
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