@[Context(Game)]
class TETU::Population < Entitas::Component
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
