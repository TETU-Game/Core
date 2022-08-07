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

module TETU::API::Definitions
  @[GraphQL::Object]
  class Planet < GraphQL::BaseObject
    @@i = 0

    @[GraphQL::Field]
    def name : String
      @@i += 1
      "my #{@@i}th planet name"
    end
  end

  @[GraphQL::Object]
  class Empire < GraphQL::BaseObject
    @[GraphQL::Field]
    def name : String
      "my empire name"
    end

    @[GraphQL::Field]
    def planets : Array(Planet)
      [Planet.new, Planet.new]
    end
  end

  @[GraphQL::Object]
  class GameQuery < GraphQL::BaseQuery
    @[GraphQL::Field]
    def hello(name : String) : String
      "Hello, #{name}!"
    end

    @[GraphQL::Field]
    def empire : Empire
      Empire.new
    end
  end
end

schema = GraphQL::Schema.new(TETU::API::Definitions::GameQuery.new)

post "/graphql" do |env|
  env.response.content_type = "application/json"

  query = env.params.json["query"].as(String)
  variables = env.params.json["variables"]?.as(Hash(String, JSON::Any)?)
  operation_name = env.params.json["operationName"]?.as(String?)

  schema.execute(query, variables, operation_name)
end
