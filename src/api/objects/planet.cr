module TETU::API::Definitions
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
end
