require "../components"

class EconomicProductionSystem
  include Entitas::Systems::ExecuteSystem

  def initialize(@context : GameContext); end

  def execute
    # populated = @context.get_group Entitas::Matcher.all_of Named, Population
    # populated.entities.each do |e|
    #   STDERR.puts "this named populated entity is #{e.named.to_s} and has #{e.population.to_s} pop"
    # end

    producer = @context.get_group Entitas::Matcher.all_of Resources
    producer.entities.each do |e|
      e.resources.productions.each do |inout, prod_speed|
        input_storage = inout[:input].nil? ? nil : e.resources.storages[inout[:input]]
        output_storage = e.resources.storages[inout[:output]]
        deleted_input = Resources.required_input(prod_speed)
        added_output = prod_speed[:max_speed]
        if input_storage && deleted_input < input_storage[:amount]
          # error no enough input
        elsif output_storage[:amount] >= output_storage[:max]
          # error output full
        else
          e.resources.storages[inout[:output]] = Resources::Store.new(
            amount: e.resources.storages[inout[:output]][:amount] + added_output,
            max: e.resources.storages[inout[:output]][:max],
          )
          # e.resources.storages[inout[:input]] = Resources::Store.new(
          #   amount: e.resources.storages[inout[:input]][:amount] - deleted_input,
          #   max: e.resources.storages[inout[:input]][:max],
          # ) if input_storage

          # input_storage[:amount] -= deleted_input if input_storage
          # output_storage[:amount] += added_output
          # add error checking
        end
      end
    end
  end
end
