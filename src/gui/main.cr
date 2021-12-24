require "crsfml"

class Gui::Main
  WIDTH = 800
  HEIGHT = 600
  GALAXY = SF::Texture.from_file("assets/#{WIDTH}x#{HEIGHT}/galaxy.jpg")

  @window : SF::RenderWindow

  def initialize
    @window = SF::RenderWindow.new(SF::VideoMode.new(WIDTH, HEIGHT), "My window")
  end

  def start(hw)
    hw.start
    i = 0u64
    while @window.open?
      while event = @window.poll_event
        case event
        when SF::Event::Closed
          @window.close
        when SF::Event::KeyPressed
          puts "pressed #{event}"
        end
      end

      @window.clear(SF::Color::Black)
      sprite = SF::Sprite.new(GALAXY)
      @window.draw(sprite)
      draw_cadran 50
      draw_cadran 120
      draw_cadran 220
      draw_cadran 350
      @window.display

      i += 1
      puts "Tic #{i}"
      Fiber.yield
      hw.update
    end
  end

def draw_cadran(size)
    circle = SF::CircleShape.new
    circle.radius = size
    circle.outline_color = SF::Color::White
    circle.fill_color = SF::Color::Transparent
    circle.outline_thickness = 1
    circle.point_count = 500
    circle.position = {WIDTH / 2 - size, HEIGHT / 2 - size}
    @window.draw circle
  end
end