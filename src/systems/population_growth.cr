require "../components"

class TETU::PopulationGrowthSystem < Entitas::ReactiveSystem
  spoved_logger level: :debug, io: STDOUT, bind: true

  def initialize(@contexts : Contexts)
    @time_context = @contexts.time
    @collector = get_trigger(@time_context)
  end

  def get_trigger(context : Entitas::Context) : Entitas::ICollector
    context.create_collector(TimeMatcher.day_passed_event.added)
  end

  def execute(time_entities : Array(Entitas::IEntity))
    populateds = @contexts.game.get_group Entitas::Matcher.all_of(Population, Resources)
    populateds.entities.each do |e|
      pop_amount = e.population.amount
      foods = e.population.foods
      pop_foods_needs = foods.transform_values do |food_amount_per_pop|
        food_amount_per_pop * pop_amount
      end
      logger.debug { "pop_foods_needs=#{pop_foods_needs}" }
      logger.debug { "resouces=#{e.resources.stores}" }

      minimum_food_ratio = Ratio.minimum(pop_foods_needs, e.resources.stores.amount_hash) || 0.0
      logger.debug { "minimum_food_ratio=#{minimum_food_ratio}" }
      total_food_modifier = food_modifier(minimum_food_ratio)
      logger.debug { "total_food_modifier=#{total_food_modifier}" }

      new_pop_amount = pop_amount + pop_amount * (reproduction_rate(total_food_modifier))
      logger.debug { "population growth: #{pop_amount} * #{new_pop_amount / pop_amount} => #{new_pop_amount}" }
      e.replace_population(amount: new_pop_amount, foods: foods)
      pop_foods_needs.each do |food_id, food_need|
        logger.debug { "population food consumption: #{food_id}:#{food_need}" }
        e.resources.stores[food_id].amount -= food_need
      end if minimum_food_ratio > 0.0
    end
  end

  # we also add a modifier based on food availability
  # that can be between -5 for famine with 0 food
  # +0.0 if food required is reach no less no more
  # up to 1.0 for post-scarcity inifity food (5x food required = +0.8)
  def food_modifier(available_food_ratio : Float64)
    return -5.0 if available_food_ratio <= 0.0
    modifier = 1.0 / -available_food_ratio + 1.0
    if modifier < -5.0
      -5.0 # not worse than -5
    else
      modifier
    end
  end

  # let's say every adult make 1.5 child average in its average lifespan (80 years)
  # and one tick is one day (3 children per couple).
  def reproduction_rate(food_modifier) : Float64
    (children_per_pop_average + food_modifier) * (1.0/pop_lifespan_average) * (1.0/365.0)
  end

  def pop_per_food_per_tick : Float64
    100.0.millions
  end

  def children_per_pop_average : Float64
    1.5
  end

  def pop_lifespan_average : Float64
    80.0
  end
end
