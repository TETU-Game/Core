require "./base"
require "./planet"

module TETU::API::Definitions
  @[GraphQL::Object]
  class Star < GraphQL::BaseObject
    @@i : ID = 0

    def initialize(id : Int32? = nil)
      if id.nil?
        @id = @@i
        @@i += 1
      else
        @id = id
      end
    end

    @[GraphQL::Field]
    getter id : ID

    @[GraphQL::Field]
    def name : String
      "my #{@id}th star name"
    end
  end
end

module TETU::API::Definitions
  @[GraphQL::Object]
  class Empire < GraphQL::BaseObject
    @[GraphQL::Field]
    def name : String
      "Player"
    end

    @[GraphQL::Field]
    def stars(context) : Array(Star)
      context.player_channel.send({ "stars", TETU::API::RESPONSE_CHANNEL })
      answer = TETU::API::RESPONSE_CHANNEL.receive
      answer.split(",").map { |name| Star.new }
    end

    @[GraphQL::Field]
    def planets : Array(Planet)
      [] of Planet
    end
  end
end
