module TETU::API::Definitions
  alias ID = Int32
  @[GraphQL::Object]
  class Planet < GraphQL::BaseObject
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
      "my #{@id}th planet name"
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
end
