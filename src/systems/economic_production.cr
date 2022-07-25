require "../components"

class TETU::EconomicProductionSystem
  include Entitas::Systems::ExecuteSystem
  spoved_logger level: :info, io: STDOUT, bind: true

  def initialize(@contexts : Contexts); end

  def execute
    # populated = @contexts.game.get_group Entitas::Matcher.all_of Named, Population
    # populated.entities.each do |e|
    #   STDERR.logger.debug { "this named populated entity is #{e.named.to_s} and has #{e.population.to_s} pop" }
    # end

    producer_group = @contexts.game.get_group Entitas::Matcher.all_of(Resources, Population, ManpowerAllocation)
    producer_group.entities.each do |e|
      next if !e.resources.can_produce?

      e.resources.infras.each do |infra_id, infra|
        rate = prod_rate(infra, e)
        prod_rates = infra.prods.map { |res, prod| apply_prod(infra: infra, res: res, rate: rate, prod: prod) }
        real_prod_rate = prod_rates.empty? ? rate : prod_rates.max
        infra.consumes.each { |res, conso| apply_prod(infra: infra, res: res, rate: -real_prod_rate, prod: conso) }
        infra.wastes.each { |res, waste| apply_prod(infra: infra, res: res, rate: real_prod_rate, prod: waste) }
      end
    end

    # producer.entities.each do |e|
    #   logger.debug { "===" }
    #   logger.debug { "#{e.named.to_s} resources stats:" }
    #   e.resources.storages.each do |res, store|
    #     logger.debug { "#{res}: #{store.amount} / #{store.max}" }
    #   end
    # end
  end

  def prod_rate(infra : Resources::Infra, producer : GameEntity) : Float64
    return 1.0 if infra.consumes.empty?
    return 0.0 if infra.consumes.any? { |res, _value| infra.stores[res]?.nil? }
    # TODO: another function for pop.amount < manpower.optimal
    allocated_manpower = producer.manpower_allocation.absolute[infra.id]
    maximal_rate =
      if allocated_manpower >= infra.manpower.min
        Math.log(allocated_manpower / infra.manpower.optimal, 2) + 1.0
      else
        0.0
      end
    limited_rate = (infra.consumes.map { |res, value| infra.stores[res].amount / value } + [maximal_rate]).min
    # if infra.id == "mine" || true
    #   logger.debug { "producer.named.name=#{producer.named.name}" }
    #   logger.debug { "infra.id=#{infra.id}" }
    #   logger.debug { "allocated_manpower=#{allocated_manpower}"  }
    #   logger.debug { "infra.manpower.optimal=#{infra.manpower.optimal}"  }
    #   logger.debug { "infra.manpower.min=#{infra.manpower.min} " }
    #   logger.debug { "maximal_rate=#{maximal_rate} " }
    #   logger.debug { "limited_rate=#{limited_rate}"  }
    #   logger.debug { "" }
    # end
    limited_rate
  end

  # returns the real production rate, limited by the storage
  # @param rate : the maximum production we should use
  def apply_prod(infra : Resources::Infra, rate : Float64, res : Resources::Name, prod : Float64) : Float64
    # logger.debug { "apply_prod wants rate=#{rate} res=#{res} prod=#{prod}" }
    store = infra.stores[res]?
    if store.nil? || rate > 0 && store.amount == store.max
      # logger.debug { "apply_prod applied rate=0.0 res=#{res} prod=#{prod}" }
      return 0.0
    end

    # computes the amount we wanted to produce
    max_prod = prod * rate
    new_amount = store.amount + max_prod
    # if no space, reduce production rate to have full storage, not more
    if new_amount > store.max
      # recompute a lower rate of production that will be applied to consumption
      rate = (store.max - store.amount) / prod
      new_amount = store.max
    end

    store.amount = new_amount

    # logger.debug { "apply_prod applied rate=#{rate} res=#{res} prod=#{prod}" }

    return rate
  end
end
