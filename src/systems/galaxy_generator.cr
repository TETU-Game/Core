class GalaxyInitializerSystem
  include Entitas::Systems::InitializeSystem

  def initialize(@context : GameContext); end

  SYSTEMS_AMOUNT = 2

  def init
    stars = SYSTEMS_AMOUNT.times.map do |i|
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
