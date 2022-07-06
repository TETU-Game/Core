require "log"
require "yaml"

require "entitas"
require "crsfml"
require "imgui"
require "imgui-sfml"

module TETU
  LOG_FORMATTER = ::Log::IOBackend.new(formatter: ::Log::ShortFormat)
  ::Log.setup(:debug, LOG_FORMATTER) # Log debug and above for all

  Log = ::Log.for("tetu")

  # TO BE USED
  module Systems
    Log = TETU::Log.for("systems")
  end

  # TO BE USED
  module Components
    Log = TETU::Log.for("components")
  end

  module Helpers
  end
end

require "./helpers/*"
require "./core/*"

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

hw = TETU::MainWorld.new
hw.start

i = 0i64
stop_at = ARGV.size > 0 ? ARGV[0].to_u64 : -1i64
loop do
  t1 = Time.local
  i += 1
  Log.debug { "=============== START TICK #{i} ===============" }
  Fiber.yield
  hw.update
  exit if i == stop_at
  Log.debug { "=============== FINISH TICK #{i} ===============" }
  t2 = Time.local
  Log.debug { "Duration: #{t2 - t1}" }
  Log.debug { "" }
end
