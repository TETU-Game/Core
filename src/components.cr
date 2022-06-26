require "./blueprint"

@[Context(Game)]
class Named < Entitas::Component
  prop :name, String, default: "unamed"

  STAR_NAMES = Blueprint.load_list "stars", "names.txt"

  @@star_id = 0
  def self.generate_star(star)
    name = STAR_NAMES[@@star_id]
    @@star_id = (@@star_id + 1) % STAR_NAMES.size
    star.add_named name: name
  end

  def to_s
    "\"#{@name}\""
  end
end

@[Context(Game)]
class CelestialBody < Entitas::Component
  prop :type, Symbol, default: :default

  TYPES = %i(asteroid_belt planet star asteroid habitat)

end

@[Context(Game)]
class StellarPosition < Entitas::Component
  prop :body_index, Int32, default: 0
  prop :moon_index, Int32, default: 0

  def to_s
    "[#{@body_index}+#{@moon_index}]"
  end
end

# Galactic position
@[Context(Game)]
class Position < Entitas::Component
  prop :x, Int32, default: 0
  prop :y, Int32, default: 0

  MAX_X = TETU::MAX_X
  MAX_Y = TETU::MAX_Y

  def self.generate(entity)
    entity.add_position x: (0..MAX_X).sample, y: (0..MAX_Y).sample
  end

  def to_s
    "#{@x}:#{@y}"
  end

  def copy_to(entity)
    entity.add_position x: @x, y: @y
  end

  def ==(right : Position)
    @x == right.x && @y == right.y
  end

  def !=(right : Position)
    @x != right.x || @y != right.y
  end
end

@[Context(Game)]
class Moving < Entitas::Component
  prop :x, Int32, default: 0
  prop :y, Int32, default: 0
end

@[Context(Game)]
class Population < Entitas::Component
  prop :amount, Float64, default: 0.0

  MIN_RANDOM_POP = 10_000.0
  MAX_RANDOM_POP = 10_000_000_000.0
  def self.generate(entity)
    entity.add_population amount: (MIN_RANDOM_POP..MAX_RANDOM_POP).sample.round
  end

  def to_s
    Helpers::Numbers.humanize(number: @amount, round: 2)
  end
end

@[Context(Game)]
class ShowState < Entitas::Component
  prop :gui, Bool, default: false
  prop :resources, Bool, default: false

  def to_s
    "ShowState: gui(#{@gui}) resources(#{resources})"
  end
end

require "./components/resources"

class InfrastructureUpgrade
  alias Costs = Hash(Resources::Name, Float64)
  property id : String
  property costs_by_tick : Costs
  property costs_start : Costs
  property end_tick : TETU::Tick
  property current_tick : TETU::Tick
  @finished = false

  def to_s
    "#{@id} (#{@current_tick}/#{@end_tick})"
  end

  def finished?
    @finished
  end

  def finish!
    @finished = true
  end

  def initialize(@id, @costs_by_tick, @costs_start, @end_tick, @current_tick = 0i64)
  end

  def self.from_infrastructure(id : String, tier : Int32)
    # TODO: must read the properties of the blueprints to define the costs
    free_instant(id)
  end

  def self.free_instant(id : String)
    new(
      id: id,
      costs_by_tick: Costs.new,
      costs_start: Costs.new,
      end_tick: 0i64,
      current_tick: 0i64,
    )
  end
end

@[Context(Game)]
class InfrastructureUpgrades < Entitas::Component
  prop :upgrades, Array(InfrastructureUpgrade), default: Array(InfrastructureUpgrade).new

  def to_s
    "InfrastructureUpgrades: #{upgrades.map(&.to_s)}"
  end

  def self.default_upgrades_for_populated_body
    [
      InfrastructureUpgrade.free_instant(id: "e_store"),
      InfrastructureUpgrade.free_instant(id: "m_store"),
      InfrastructureUpgrade.free_instant(id: "f_store"),

      InfrastructureUpgrade.free_instant(id: "e_plant"),
      InfrastructureUpgrade.free_instant(id: "mine"),
      InfrastructureUpgrade.free_instant(id: "farm"),

      InfrastructureUpgrade.free_instant(id: "a_store"),
      InfrastructureUpgrade.free_instant(id: "l_store"),

      InfrastructureUpgrade.free_instant(id: "a_plant"),
      InfrastructureUpgrade.free_instant(id: "l_plant"),
    ]
  end
end

require "./components/*"
