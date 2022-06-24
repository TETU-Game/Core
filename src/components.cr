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

  BILLION = 1_000_000_000
  MILLION = 1_000_000
  THOUSAND = 1_000
  ROUNDING = 2
  def to_s
    if @amount > BILLION
      "#{(@amount / BILLION).round(ROUNDING)}B"
    elsif @amount > MILLION
      "#{(@amount / MILLION).round(ROUNDING)}M"
    elsif @amount > THOUSAND
      "#{(@amount / THOUSAND).round(ROUNDING)}K"
    else
      @amount.to_s
    end
  end
end

@[Context(Game)]
class Resources < Entitas::Component
  DESCRIPTIONS = Blueprint.load_yaml("resources", "descriptions.yaml").as_h
  LIST = %i[food food2 mineral mineral2 alloy alloy2 chemical weapon]

  alias Store = { amount: Float64, max: Float64 }
  # TODO: this should probably be a NamedTuple instead
  alias Stores = Hash(Symbol, Store)
  prop :storages, Stores

  alias InOut = { input: Symbol, output: Symbol }
  alias ProdSpeed = { rate: Float64, max_speed: Float64 }
  alias Prods = Hash(InOut, ProdSpeed)
  prop :productions, Prods

  def self.default
    stores = Stores.new
    LIST.each do |res_name|
      stores[res_name] = Store.new(amount: 0.0, max: 1.0)
    end

    prods = Prods.new

    Resources.new(storages: stores, productions: prods)
  end

  def self.default_populated
    r = default()
    r.storages[:food] =    Store.new(amount: 0.0, max: 1000.0)
    r.storages[:mineral] = Store.new(amount: 0.0, max: 10000.0)
    r.storages[:alloy] =   Store.new(amount: 0.0, max: 10000.0)

    r.productions[InOut.new(input: :nil, output: :food)] = ProdSpeed.new(rate: 1.0, max_speed: 20.0)
    r.productions[InOut.new(input: :nil, output: :mineral)] = ProdSpeed.new(rate: 1.0, max_speed: 10.0)
    r.productions[InOut.new(input: :mineral, output: :alloy)] = ProdSpeed.new(rate: 1.0, max_speed: 0.1)

    r
  end

  def self.required_input(prod_speed : ProdSpeed)
    prod_speed[:max_speed] / prod_speed[:rate]
  end

  def add(resource : Symbol, amount : Number)
    storages[resource] = {
      amount: storages[resource][:amount] + amount,
      max: storages[resource][:max],
    }
  end

  def upgrade(upgrade : ResourcesUpgrades::ResourceUpgrade)
    resource = upgrade[:resource]
    upgrade[:costs].each do |cost_resource, cost_amount|
      add cost_resource, -cost_amount
    end
    storages[resource] = {
      amount: storages[resource][:amount],
      max: storages[resource][:max] + upgrade[:storages][:max],
    }
  end

  def to_s
    stores_to_s = storages.map{ |k, v| "#{k}=#{v[:amount]}/#{v[:max]}" }.join(" ")
    productions_to_s = productions? ? productions.map { |io, speed| "#{io[:input]}=>#{io[:output]}x#{speed[:rate]}" }.join(" ") : "?"
    "Resources: store{#{stores_to_s}} production={#{productions_to_s}}}"
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

@[Context(Game)]
class ResourcesUpgrades < Entitas::Component
  alias ResourceUpgrade = {
    resource: Symbol,
    storages: { max: Float64 },
    costs: Hash(Symbol, Float64),
  }
  prop :upgrades, Array(ResourceUpgrade), default: Array(ResourceUpgrade).new
end

require "./components/*"
