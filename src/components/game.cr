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

  def self.from_blueprint(infra_id : String, tier : Number)
    blueprint = Helpers::InfrastructuresFileLoader.all[infra_id]
    total_costs = blueprint.build.costs.transform_values { |f| f.execute(tier) }
    upfront_costs = total_costs.transform_values { |v| v * blueprint.build.upfront }
    duration = blueprint.build.duration.execute(tier)
    tick_costs = total_costs.transform_values { |v| v * (1.0 - blueprint.build.upfront) / duration }
    Log.debug { "" }
    Log.debug { "> Create from blueprint" }
    upgrade = new(
      id: infra_id,
      costs_by_tick: tick_costs,
      costs_start: upfront_costs,
      end_tick: duration.to_i64,
      current_tick: 0i64,
    )
    Log.debug { { blueprint: blueprint } }
    Log.debug { { upgrade: upgrade } }
    Log.debug { "" }
    upgrade
  end
end

@[Context(Game)]
class TETU::InfrastructureUpgrades < Entitas::Component
  prop :upgrades, Array(InfrastructureUpgrade), default: Array(InfrastructureUpgrade).new

  def to_s
    "InfrastructureUpgrades: #{upgrades.map(&.to_s)}"
  end
end

require "./game/*"
