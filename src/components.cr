require "./blueprint"

@[Context(Game)]
class Named < Entitas::Component
  prop :name, String, default: "unamed"

  SYSTEM_NAMES = Blueprint.load_list "systems", "names.txt"

  def self.generate_planet(entity)
    number = (1..10).sample
    moon = (1..2).sample == 1 ? "" : ("a".."d").sample # 20 moons max should be t
    system = SYSTEM_NAMES.sample
    entity.add_named name: "#{system} #{number}#{moon}"
  end
end

@[Context(Game)]
class Position < Entitas::Component
  prop :x, Int32, default: 0
  prop :y, Int32, default: 0
end

@[Context(Game)]
class Moving < Entitas::Component
  prop :x, Int32, default: 0
  prop :y, Int32, default: 0

  MAX_X = 100
  MAX_y = 100

  def self.generate(entity)
    entity.add_moving x: (0..MAX_X).sample, y: (0..MAX_Y).sample
  end
end

@[Context(Game)]
class Population < Entitas::Component
  prop :amount, Float64, default: 0.0

  MIN_RANDOM_POP = 10_000.0
  MAX_RANDOM_POP = 10_000_000_000.0
  def self.generate(entity)
    entity.add_population amount: (MIN_RANDOM_POP..MAX_RANDOM_POP).sample.round
  end
end

@[Context(Game)]
class ResourceStorage < Entitas::Component
  prop :resource, UInt64, default: 0
  prop :amount, Float64, default: 0.0
  prop :max, Float64, default: 0.0
end

@[Context(Game)]
class ResourceTransformation < Entitas::Component
  prop :input, UInt64, default: 0
  prop :output, UInt64, default: 0
  prop :rate, Float64, default: 0.0
  prop :max, Float64, default: 0.0
end
