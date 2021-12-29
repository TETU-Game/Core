require "../components"
require "crsfml"
require "imgui"
require "imgui-sfml"

class MainUiSystem
  include Entitas::Systems::ExecuteSystem
  include Entitas::Systems::InitializeSystem

  GALAXY_WIDTH = TETU::MAX_X
  GALAXY_HEIGHT = TETU::MAX_Y
  UI_WIDTH = GALAXY_WIDTH + TETU::UI_CONF["right_sidebar"].as_i64
  UI_HEIGHT = GALAXY_HEIGHT
  SQUARE_SIZE = TETU::UI_CONF["square_size"].as_i64

  GALAXY = SF::Texture.from_file("assets/#{GALAXY_WIDTH}x#{GALAXY_HEIGHT}/galaxy.jpg")

  @window : SF::RenderWindow
  
  def initialize(@context : GameContext)
    @window = SF::RenderWindow.new(
      SF::VideoMode.new(UI_WIDTH, UI_HEIGHT),
      "To the End of The Universe",
    )
    @delta_clock = SF::Clock.new
  end

  def init
    ImGui::SFML.init(@window)
    @window.framerate_limit = TETU::UI_CONF["framerate"].as_i64
  end
  
  def execute
    if !@window.open?
      exit(0)
    end

    handle_events
    ImGui::SFML.update(@window, @delta_clock.restart)
    @window.clear(SF::Color::Black)
    
    draw_background
    draw_galay_menu

    ImGui::SFML.render(@window)
    @window.display
  end

  private def handle_events
    while event = @window.poll_event
      ImGui::SFML.process_event(@window, event)
      
      case event
      when SF::Event::Closed
        @window.close
      when SF::Event::KeyPressed
        puts "KeyPressed #{event}"
      when SF::Event::MouseButtonEvent
        puts "MouseButtonEvent #{event}"
      end
    end
  end

  private def draw_background
    sprite = SF::Sprite.new(GALAXY)
    @window.draw(sprite)
    # draw_cadran 50
    # draw_cadran 120
    # draw_cadran 220
    # draw_cadran 350
    draw_grid
    draw_stars_on_grid
  end

  private def draw_cadran(size)
    circle = SF::CircleShape.new
    circle.radius = size
    circle.outline_color = SF::Color::White
    circle.fill_color = SF::Color::Transparent
    circle.outline_thickness = 1
    circle.point_count = 500
    circle.position = { GALAXY_WIDTH / 2 - size, GALAXY_HEIGHT / 2 - size }
    @window.draw circle
  end

  private def draw_grid
    (0...(GALAXY_WIDTH / SQUARE_SIZE)).each do |x|
      (0...(GALAXY_HEIGHT / SQUARE_SIZE)).each do |y|
        square = SF::RectangleShape.new(SF.vector2(SQUARE_SIZE, SQUARE_SIZE))
        square.outline_color = SF::Color::White
        square.fill_color = SF::Color::Transparent
        square.outline_thickness = 1
        square.position = { x * SQUARE_SIZE, y * SQUARE_SIZE }
        @window.draw square
      end
    end
  end

  private def draw_stars_on_grid
    stars = @context.get_group Entitas::Matcher.all_of(Named, Position, CelestialBody).none_of(StellarPosition)
    stars.entities.each do |entity|
      position = entity.position
      square = SF::RectangleShape.new(SF.vector2(1, 1))
      square.position = { position.x, position.y }
      square.outline_color = SF::Color::Red
      square.fill_color = SF::Color::Red
      square.outline_thickness = 1
      @window.draw square
    end
  end

  private def draw_galay_menu
    if ImGui.begin(name: "right side", flags: ImGui::ImGuiWindowFlags.new(0))
      ImGui.set_window_pos("right side", ImGui::ImVec2.new(GALAXY_WIDTH, 0))
      ImGui.set_window_size("right side", ImGui::ImVec2.new(400, GALAXY_HEIGHT))
      if ImGui.tree_node_ex("galaxy infos", ImGui::ImGuiTreeNodeFlags.new(ImGui::ImGuiTreeNodeFlags::DefaultOpen))
        if ImGui.tree_node_ex "Stars", ImGui::ImGuiTreeNodeFlags.new(ImGui::ImGuiTreeNodeFlags::DefaultOpen)
          draw_stars_menu
          ImGui.tree_pop
        end
        ImGui.tree_pop
      end
    end
    ImGui.end
  end

  private def draw_stars_menu
    stars = @context.get_group Entitas::Matcher.all_of(Named, Position, CelestialBody).none_of(StellarPosition)
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
    planets = @context.get_group Entitas::Matcher.all_of(Named, Position, CelestialBody, StellarPosition, ShowState)
    planets.entities.each do |planet|
      next if star.position != planet.position

      text = "#{planet.named.name} | #{planet.stellar_position.to_s}"
      text += " | pop #{planet.population.to_s}" if planet.has_component?(Population.index_val)
      ImGui.text text
      toggle_planet_show_state_resources planet if ImGui.is_item_clicked

      draw_planet_resource_menu planet if planet.show_state.resources == true
    end
  end

  private def toggle_planet_show_state_resources(planet)
    show_state = planet.show_state
    if planet.has_component? Resources.index_val
      show_state.resources = !show_state.resources
    end
  end

  UPGRADE_MINERAL_COST = 100.0
  private def draw_planet_resource_menu(planet)
    resources = planet.resources
    resources.storages.each do |res, store|
      ImGui.text "\t#{res}: #{store[:amount]} / #{store[:max]}"
      toggle_planet_show_state_resources planet if ImGui.is_item_clicked
      ImGui.same_line

      can_upgrade = resources.storages[:mineral][:amount] >= UPGRADE_MINERAL_COST
      ImGui.begin_disabled if !can_upgrade
      if ImGui.button("upgrade####{res}")
        planet.add_resources_upgrades if !planet.has_component? ResourcesUpgrades.index_val
        planet.resources_upgrades.upgrades << {
          resource: res,
          storages: { max: 1000.0 },
          costs: { :mineral => UPGRADE_MINERAL_COST },
        }
      end
      ImGui.end_disabled if !can_upgrade
    end
  end
end