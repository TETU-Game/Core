class TETU::UiDrawSystem
  include Helpers::UiSystem
  include Entitas::Systems::ExecuteSystem
  spoved_logger level: :debug, io: STDOUT, bind: true
  
  def initialize(@context : GameContext); end

  def execute
    ImGui::SFML.render(window)
    window.display
  end
end
