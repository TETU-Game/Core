class TETU::UiDrawSystem
  include Helpers::UiSystem
  include Entitas::Systems::ExecuteSystem

  def initialize(@context : GameContext); end

  def execute
    ImGui::SFML.render(window)
    window.display
  end
end
