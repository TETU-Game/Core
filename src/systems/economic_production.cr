require "../components"

class EconomicProductionSystem
  include Entitas::Systems::ExecuteSystem

  def initialize(@context : GameContext); end

  def execute
    # populated = @context.get_group Entitas::Matcher.all_of Named, Population
    # populated.entities.each do |e|
    #   STDERR.puts "this named populated entity is #{e.named.to_s} and has #{e.population.to_s} pop"
    # end

    producer = @context.get_group Entitas::Matcher.all_of(Resources, Population)
    producer.entities.each do |e|
      pp e.resources
      puts "produces? => #{e.resources.can_produce?}"
      next if !e.resources.can_produce?
      rate = e.resources.prod_rate
      e.resources.prods.each { |res, prod| apply_prod(resources: e.resources, res: res, rate: rate, prod: prod) }
      e.resources.consumes.each { |res, conso| apply_prod(resources: e.resources, res: res, rate: -rate, prod: conso) }
    end

    # producer.entities.each do |e|
    #   puts "==="
    #   puts "#{e.named.to_s} resources stats:"
    #   e.resources.storages.each do |res, store|
    #     puts "#{res}: #{store.amount} / #{store.max}"
    #   end
    # end
  end

  def apply_prod(resources : Resources, rate : Float64, res : Resources::Name, prod : Float64)
    store = resources.stores[res]
    return if rate > 0 && store.amount == store.max

    new_amount = store.amount + rate * prod
    new_amount = store.max if store.amount > store.max
    store.amount = new_amount
  end
end
