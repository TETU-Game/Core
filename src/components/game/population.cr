@[Context(Game)]
class TETU::Population < Entitas::Component
  alias Food = Hash(String, Float64)
  DEFAULT_FOOD = { "food" => 1.0/100.0.millions }

  prop :amount, Float64, default: 0.0
  prop :foods, Food, default: DEFAULT_FOOD

  MIN_RANDOM_POP = 10.0.millions
  MAX_RANDOM_POP = 10.0.billions

  def self.generate_for(entity)
    entity.add_population amount: (MIN_RANDOM_POP..MAX_RANDOM_POP).sample.round
  end

  def to_s(round : Int32 = 2)
    Helpers::Numbers.humanize(number: @amount, round: round)
  end
end
