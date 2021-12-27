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

  MAX_X = 100
  MAX_Y = 100

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
  def to_s
    if @amount > BILLION
      "#{(@amount / BILLION).round 1}B"
    elsif @amount > MILLION
      "#{(@amount / MILLION).round 1}M"
    elsif @amount > THOUSAND
      "#{(@amount / THOUSAND).round 1}K"
    else
      @amount.to_s
    end
  end
end

# @[Context(Game)]
# class ResourceStorage < Entitas::Component
#   prop :resource, Symbol
#   prop :amount, Float64, default: 0.0
#   prop :max, Float64, default: 0.0
# end

# @[Context(Game)]
# class ResourceTransformation < Entitas::Component
#   prop :input, Symbol?, default: nil
#   prop :output, Symbol
#   prop :rate, Float64, default: 1.0
#   prop :max, Float64, default: 0.0
# end

@[Context(Game)]
class Resources < Entitas::Component
  alias Store = { amount: Float64, max: Float64 }
  alias Stores = Hash(Symbol, Store)
  prop :storages, Stores

  alias InOut = { input: Symbol?, output: Symbol }
  alias ProdSpeed = { rate: Float64, max_speed: Float64 }
  alias Prods = Hash(InOut, ProdSpeed)
  prop :productions, Prods

  def self.required_input(prod_speed : ProdSpeed)
    prod_speed[:max_speed] / prod_speed[:rate]
  end
end

require "./components/*"
