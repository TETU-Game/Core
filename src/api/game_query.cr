require "./objects"

module TETU::API::Definitions
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

    @[GraphQL::Field]
    def planet(id : ID? = nil) : Planet
      Planet.new(id: id)
    end
  end
end
