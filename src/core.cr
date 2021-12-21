require "entitas"

require "./components"
require "./systems/*"

class GalaxyInitializerSystem
  include Entitas::Systems::InitializeSystem

  def initialize(@context : GameContext); end

  def init
    stars = 3.times.map do |i|
      star = @context.create_entity
      star.add_celestial_body type: :star
      Position.generate star
      Named.generate_star star
    end.to_a
    group = @context.get_group Entitas::Matcher.all_of Position
    STDERR.puts "init #{group.entities.size} stars"
    group.entities.each { |entity| puts "new Star [#{entity.named.to_s}] at [#{entity.position.to_s.to_s}]" }

    stars.each do |star|
      Planet.generate @context, star
    end

    group = @context.get_group Entitas::Matcher.all_of Named, Position, StellarPosition
    STDERR.puts "init #{group.entities.size} bodies"
    group.entities.each { |entity| puts "new Body [#{entity.named.to_s}] in [#{entity.stellar_position.body_index}]" }
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
  puts "Tic #{i}"
  Fiber.yield
  hw.update
end
