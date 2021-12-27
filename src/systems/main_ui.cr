require "../components"
require "crsfml"
require "imgui"
require "imgui-sfml"

class MainUiSystem
  include Entitas::Systems::ExecuteSystem
  include Entitas::Systems::InitializeSystem

  GALAXY_WIDTH = 800
  GALAXY_HEIGHT = 600
  SQUARE_SIZE = 100

  UI_WIDTH = GALAXY_WIDTH + 400
  UI_HEIGHT = GALAXY_HEIGHT
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
    @window.framerate_limit = 60
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
        puts "pressed #{event}"
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

  private def draw_galay_menu
    if ImGui.begin(
      name: "right side",
      flags: ImGui::ImGuiWindowFlags.new(0),
    )
      ImGui.set_window_pos("right side", ImGui::ImVec2.new(GALAXY_WIDTH, 0))
      ImGui.set_window_size("right side", ImGui::ImVec2.new(400, GALAXY_HEIGHT))
      if ImGui.tree_node_ex("galaxy infos", ImGui::ImGuiTreeNodeFlags.new(ImGui::ImGuiTreeNodeFlags::DefaultOpen))
        if ImGui.tree_node_ex "Stars", ImGui::ImGuiTreeNodeFlags.new(ImGui::ImGuiTreeNodeFlags::DefaultOpen)
          draw_stars_menu
          ImGui.tree_pop
        end
        ImGui.tree_pop
      end
      ImGui.end
    end
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
    planets = @context.get_group Entitas::Matcher.all_of(Named, Position, CelestialBody, StellarPosition)
    planets.entities.each do |entity|
      next if star.position != entity.position
      ImGui.text "#{entity.named.name} | #{entity.stellar_position.to_s}"
    end
  end
end