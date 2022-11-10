class TETU::RequestHandlerSystem
  include Entitas::Systems::ExecuteSystem
  spoved_logger level: :info, io: STDOUT, bind: true

  getter player_channel : Channel(Tuple(String, Channel(String)))
  @contexts : Contexts

  def initialize(@contexts, @player_channel)
  end

  def execute
    message, responder = player_channel.receive
    if message == "stars"
      stars = @contexts.game.get_group Entitas::Matcher.all_of(Named, Position, CelestialBody, PlayerOwned).none_of(StellarPosition)
      responder.send stars.entities.map { |entity| entity.named.name }.join(",")
    else
      responder.send ""
    end
  end
end
