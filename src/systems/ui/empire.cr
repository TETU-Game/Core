# in charge to handle the main empire UI
class TETU::UiEmpireSystem
  include Entitas::Systems::ExecuteSystem

  def initialize(@context : GameContext); end

  def execute
    draw_galaxy_menu
  end

  private def draw_galaxy_menu
    draw_empire_menu_frame do
      draw_stars_menu
    end
  end

  RIGHT_SIDEBAR_SIZE = TETU::UI_CONF["right_sidebar"].as_i64

  private def draw_empire_menu_frame(&block)
    if ImGui.begin(name: "right side", flags: ImGui::ImGuiWindowFlags.new(0))
      ImGui.set_window_pos("right side", ImGui::ImVec2.new(Window::GALAXY_WIDTH, 0))
      ImGui.set_window_size("right side", ImGui::ImVec2.new(RIGHT_SIDEBAR_SIZE, Window::GALAXY_HEIGHT))
      if ImGui.tree_node_ex("galaxy infos", ImGui::ImGuiTreeNodeFlags.new(ImGui::ImGuiTreeNodeFlags::DefaultOpen))
        if ImGui.tree_node_ex "Stars", ImGui::ImGuiTreeNodeFlags.new(ImGui::ImGuiTreeNodeFlags::DefaultOpen)
          yield
          ImGui.tree_pop
        end
        ImGui.tree_pop
      end
    end
    ImGui.end
  end

  private def draw_stars_menu
    stars = @context.get_group Entitas::Matcher.all_of(Named, Position, CelestialBody, PlayerOwned).none_of(StellarPosition)
    stars.entities.each do |entity|
      draw_star_menu_one_star(entity)
    end
  end

  private def draw_star_menu_one_star(star)
    if ImGui.tree_node_ex "#{star.named.name} | #{star.position.to_s}", ImGui::ImGuiTreeNodeFlags.new(ImGui::ImGuiTreeNodeFlags::DefaultOpen)
      draw_planets_menu star
      ImGui.tree_pop
    end
  end

  private def draw_planets_menu(star)
    planets = @context.get_group Entitas::Matcher.all_of(Named, Position, CelestialBody, StellarPosition, PlayerOwned)
    planets.entities.each do |planet|
      next if star.position != planet.position

      text = "#{planet.named.name} | #{planet.stellar_position.to_s}"
      text += " | pop #{planet.population.to_s}" if planet.has_population?
      ImGui.text text
      toggle_planet_show_state_resources planet if ImGui.is_item_clicked
    end
  end

  private def toggle_planet_show_state_resources(planet)
    TETU::Window.instance.planet_menu_selected = planet
  end

end
