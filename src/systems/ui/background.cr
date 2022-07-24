class TETU::UiBackgroundSystem
  include Entitas::Systems::ExecuteSystem
  include Helpers::UiSystem
  spoved_logger level: :info, io: STDOUT, bind: true

  def initialize(@context : GameContext); end

  def execute
    draw_background
  end

  private def draw_background
    sprite = SF::Sprite.new(Window::GALAXY)
    window.draw(sprite)
    # draw_cadran 50
    # draw_cadran 120
    # draw_cadran 220
    # draw_cadran 350
    draw_grid
    draw_stars_on_grid # TODO FIXME: THIS LINE IS ULTRA SLOW (99% of computation time)
  end

  private def draw_cadran(size)
    circle = SF::CircleShape.new
    circle.radius = size
    circle.outline_color = SF::Color::White
    circle.fill_color = SF::Color::Transparent
    circle.outline_thickness = 1
    circle.point_count = 500
    circle.position = {GALAXY_WIDTH / 2 - size, GALAXY_HEIGHT / 2 - size}
    window.draw circle
  end

  private def draw_grid
    (0...(Window::GALAXY_WIDTH / Window::SQUARE_SIZE)).each do |x|
      (0...(Window::GALAXY_HEIGHT / Window::SQUARE_SIZE)).each do |y|
        square = SF::RectangleShape.new(SF.vector2(Window::SQUARE_SIZE, Window::SQUARE_SIZE))
        square.outline_color = SF::Color::White
        square.fill_color = SF::Color::Transparent
        square.outline_thickness = 1
        square.position = {x * Window::SQUARE_SIZE, y * Window::SQUARE_SIZE}
        window.draw square
      end
    end
  end

  private def draw_stars_on_grid
    stars = @context.get_group Entitas::Matcher.all_of(Named, Position, CelestialBody).none_of(StellarPosition)
    stars.entities.each do |entity|
      position = entity.position
      square = SF::RectangleShape.new(SF.vector2(1, 1))
      square.position = {position.x, position.y}
      square.outline_color = SF::Color::Red
      square.outline_color = SF::Color::Blue if entity.has_player_owned?
      square.fill_color = SF::Color::Red
      square.outline_thickness = 1
      square.outline_thickness = 5 if entity.has_player_owned?
      window.draw square
    end
  end
end
