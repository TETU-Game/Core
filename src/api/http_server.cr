class TETU::API::HttpServer
  def self.start
    spawn do
      Kemal.run do |config|
        server = config.server.not_nil!
        server.bind_tcp "127.0.0.1", (ENV["PORT"] || "3000").to_i
      end
    end
  end
end

require "./game_query"

schema = GraphQL::Schema.new(TETU::API::Definitions::GameQuery.new)

post "/graphql" do |env|
  env.response.content_type = "application/json"

  query = env.params.json["query"].as(String)
  variables = env.params.json["variables"]?.as(Hash(String, JSON::Any)?)
  operation_name = env.params.json["operationName"]?.as(String?)

  schema.execute(query, variables, operation_name)
end
