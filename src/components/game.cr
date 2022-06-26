@[Context(Game)]
class TETU::Named < Entitas::Component
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

require "./game/resources"

class TETU::InfrastructureUpgrade
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
class TETU::InfrastructureUpgrades < Entitas::Component
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

require "./game/*"
