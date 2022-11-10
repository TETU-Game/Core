module TETU::API::Definitions
  alias ID = Int32

  class PlayerContext < GraphQL::Context
    def initialize(@player_channel : Channel(Tuple(String, Channel(String))))
    end
  end
end
