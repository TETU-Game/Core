require "../components"

class TETU::PopulationGrowthSystem
  include Entitas::Systems::ExecuteSystem

  def initialize(@context : GameContext); end

  def execute
    populateds = @context.get_group Entitas::Matcher.all_of(Population)
    populateds.entities.each do |e|
      pop_amount = e.population.amount
      # let's say every adult make 1.5 child average in its average lifespan (80 years)
      # and one tick is one day
      reproduction_rate = 1.5 * (1.0/80.0) * (1.0/365)
      new_pop_amount = pop_amount + pop_amount * reproduction_rate
      # Log.debug { "population growth: {reproduction_rate:#{reproduction_rate}} {population:#{e.population.to_s}} {bonus:#{pop_amount * reproduction_rate}}" }
      e.replace_population(amount: new_pop_amount)
    end
  end

end
