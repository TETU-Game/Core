class TETU::UiPlanetSystem
  spoved_logger level: :debug, io: STDOUT, bind: true

  include Entitas::Systems::ExecuteSystem
  include Helpers::UiSystem

  def initialize(@context : GameContext); end

  def execute
    planet = TETU::Window.instance.planet_menu_selected
    return if planet.nil?
    draw_planet(planet)
  end

  # NOTE: this is a weird pattern, maybe stick to not parameterize the panels?
  private def draw_planet(planet : GameEntity)
    draw_planet_frame(planet)
  end

  LEFT_SIDEBAR_SIZE = TETU::UI_CONF["left_sidebar"].as_i64

  private def draw_planet_frame(planet)
    infra_ui = UiService::PlanetInfrastructure.new(planet)
    manpower_ui = UiService::PlanetManpower.new(planet)
    if ImGui.begin(name: "left side", flags: ImGui::ImGuiWindowFlags.new(0))
      ImGui.set_window_pos("left side", ImGui::ImVec2.new(0, 0))
      ImGui.set_window_size("left side", ImGui::ImVec2.new(LEFT_SIDEBAR_SIZE, Window::GALAXY_HEIGHT))
      infra_ui.draw
      manpower_ui.draw
    end
    ImGui.end
  end


end
