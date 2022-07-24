# require "log"
require "yaml"

require "entitas"
require "crsfml"
require "imgui"
require "imgui-sfml"
require "spoved/logger"

module TETU
  spoved_logger level: :debug, io: STDOUT, bind: true

  # TO BE USED
  module Systems
    # Log = TETU::Log.for(self)
    spoved_logger level: :debug, io: STDOUT, bind: true
  end

  # TO BE USED
  module Components
    # Log = TETU::Log.for(self)
    spoved_logger level: :debug, io: STDOUT, bind: true
  end

  module Helpers
  end

  @@tick = 0i64

  def self.tick(&block)
    yield @@tick
    @@tick += 1
  end

  def self.tick
    @@tick
  end
end

require "./helpers/*"
require "./core/*"
require "./ui_service"
require "./components"
require "./systems"

class TETU::EconomicSystems < Entitas::Feature
  def initialize(contexts : Contexts)
    @name = "Economic Systems"
    ctx = contexts.game # I think this is the link with @[Context(Game)] :thinking:
    add EconomicProductionSystem.new(ctx)
    add GalaxyInitializerSystem.new(ctx)
    add InfrastructureUpgradesSystem.new(ctx)
    add PopulationGrowthSystem.new(ctx)
  end
end

class TETU::UiSystems < Entitas::Feature
  def initialize(contexts : Contexts)
    @name = "UI Systems"
    ctx = contexts.game

    add UiInitSystem.new(ctx)
    add UiBackgroundSystem.new(ctx)
    add UiEmpireSystem.new(ctx)
    add UiPlanetSystem.new(ctx)
    add UiDrawSystem.new(ctx) # keep at the end
  end
end

class TETU::MainWorld
  getter systems : Entitas::Systems = Entitas::Systems.new

  def start
    # get a reference to the contexts
    contexts = Contexts.shared_instance

    # create the systems by creating individual features
    @systems = Entitas::Feature.new("systems")
      .add(EconomicSystems.new(contexts))
      .add(UiSystems.new(contexts))
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

# require "./gui/*"

module TETU
  def self.main_loop
    hw = TETU::MainWorld.new
    hw.start

    stop_at = ARGV.size > 0 ? ARGV[0].to_u64 : -1i64
    loop do
      TETU.tick do |tick|
        t1 = Time.local
        Log.info { "=============== START TICK #{tick} ===============" }
        Fiber.yield
        hw.update
        exit if tick == stop_at
        Log.info { "=============== FINISH TICK #{tick} ===============" }
        t2 = Time.local
        logger.debug { "Duration: #{t2 - t1}" }
        logger.debug { "" }
      end
    end
  end
end

TETU.main_loop
