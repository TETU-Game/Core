class TETU::UiDrawSystem
  include Helpers::UiSystem
  include Entitas::Systems::ExecuteSystem
  spoved_logger level: :info, io: STDOUT, bind: true

  def initialize(@contexts : Contexts); end

  def execute
    ImGui::SFML.render(window)
    window.display
  end
end
