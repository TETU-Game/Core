# require "log"
require "yaml"

require "entitas"
require "crsfml"
require "imgui"
require "imgui-sfml"
require "spoved/logger"

module TETU
  spoved_logger level: :info, io: STDOUT, bind: true

  # TO BE USED
  module Systems
    # Log = TETU::Log.for(self)
    spoved_logger level: :info, io: STDOUT, bind: true
  end

  # TO BE USED
  module Components
    # Log = TETU::Log.for(self)
    spoved_logger level: :info, io: STDOUT, bind: true
  end

  module Helpers
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
    add EconomicProductionSystem.new(contexts)
    add GalaxyInitializerSystem.new(contexts)
    add InfrastructureUpgradesSystem.new(contexts)
    add PopulationGrowthSystem.new(contexts)
  end
end

class TETU::UiSystems < Entitas::Feature
  def initialize(contexts : Contexts)
    @name = "UI Systems"

    add UiInitSystem.new(contexts)
    add UiBackgroundSystem.new(contexts)
    add UiEmpireSystem.new(contexts)
    add UiPlanetSystem.new(contexts)
    add UiDrawSystem.new(contexts) # keep at the end
  end
end

class TETU::TimeSystems < Entitas::Feature
  def initialize(contexts : Contexts)
    @name = "Time Systems"

    add TimeSystem.new(contexts)
  end
end

class TETU::MainWorld
  getter systems : Entitas::Systems = Entitas::Systems.new

  def start
    # get a reference to the contexts
    contexts = Contexts.shared_instance

    # create the systems by creating individual features
    @systems = Entitas::Feature.new("systems")
      .add(TimeSystems.new(contexts))
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

module TETU
  @@tick = 0i64

  def self.tick(&block)
    yield @@tick
    @@tick += 1
  end

  def self.tick
    @@tick
  end

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
