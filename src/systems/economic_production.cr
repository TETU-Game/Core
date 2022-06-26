require "../components"

class TETU::EconomicProductionSystem
  include Entitas::Systems::ExecuteSystem

  def initialize(@context : GameContext); end

  def execute
    # populated = @context.get_group Entitas::Matcher.all_of Named, Population
    # populated.entities.each do |e|
    #   STDERR.puts "this named populated entity is #{e.named.to_s} and has #{e.population.to_s} pop"
    # end

    producer = @context.get_group Entitas::Matcher.all_of(Resources, Population)
    producer.entities.each do |e|
      puts ""
      puts "produces? => #{e.resources.can_produce?}"
      next if !e.resources.can_produce?

      e.resources.infras.each do |infra_id, infra|
        rate = infra.prod_rate
        puts "#{infra_id} computed rate=#{rate} with"
        puts infra.humanize

        prod_rates = infra.prods.map { |res, prod| apply_prod(infra: infra, res: res, rate: rate, prod: prod) }
        real_prod_rate = prod_rates.empty? ? rate : prod_rates.max
        infra.consumes.each { |res, conso| apply_prod(infra: infra, res: res, rate: -real_prod_rate, prod: conso) }
        infra.wastes.each { |res, waste| apply_prod(infra: infra, res: res, rate: real_prod_rate, prod: waste) }
      end
    end

    # producer.entities.each do |e|
    #   puts "==="
    #   puts "#{e.named.to_s} resources stats:"
    #   e.resources.storages.each do |res, store|
    #     puts "#{res}: #{store.amount} / #{store.max}"
    #   end
    # end
  end

  # returns the real production rate, limited by the storage
  def apply_prod(infra : Resources::Infra, rate : Float64, res : Resources::Name, prod : Float64) : Float64
    puts "apply_prod wants rate=#{rate} res=#{res} prod=#{prod}"
    store = infra.stores[res]?
    if store.nil? || rate > 0 && store.amount == store.max
      puts "apply_prod applied rate=0.0 res=#{res} prod=#{prod}"
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

    puts "apply_prod applied rate=#{rate} res=#{res} prod=#{prod}"

    return rate
  end
end
