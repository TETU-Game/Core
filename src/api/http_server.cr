class TETU::API::HttpServer
  def self.start
    spawn do
      Kemal.run do |config|
        server = config.server.not_nil!
        server.bind_tcp(
          host: ENV.fetch("HOST", "127.0.0.1"),
          port: ENV.fetch("PORT", "3000").to_i,
        )
      end
    end
  end
end

require "./game_query"

schema = GraphQL::Schema.new(TETU::API::Definitions::GameQuery.new)


# class CustomHandler < Kemal::Handler
#   only ["/graphql"], "POST"

#   def call(context)
#     puts "Doing some custom stuff here"
#     spawn do
#       puts "Async stuff finished now"
#       call_next context
#     end
#   end
# end
# add_handler CustomHandler.new

module TETU::API
  PLAYER_CHANNEL = Channel(Tuple(String, Channel(String))).new
  RESPONSE_CHANNEL = Channel(String).new
end

post "/graphql" do |env|
  env.response.content_type = "application/json"

  query = env.params.json["query"].as(String)
  variables = env.params.json["variables"]?.as(Hash(String, JSON::Any)?)
  operation_name = env.params.json["operationName"]?.as(String?)
  context = TETU::API::Definitions::PlayerContext.new(TETU::API::PLAYER_CHANNEL)
  schema.execute(query, variables, operation_name, context)
end

get "/" do |env|
  "<html></html>"
end
