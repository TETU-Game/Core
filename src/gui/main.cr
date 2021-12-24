require "crsfml"

class Gui::Main
  GALAXY = SF::Texture.from_file("assets/800x600/galaxy.jpg")

  def initialize(hw)
    window = SF::RenderWindow.new(SF::VideoMode.new(800, 600), "My window")
    hw.start
    
    i = 0u64
    while window.open?
      while event = window.poll_event
        case event
        when SF::Event::Closed
          window.close
        when SF::Event::KeyPressed
          puts "pressed #{event}"
        end
      end

      window.clear(SF::Color::Black)
      sprite = SF::Sprite.new(GALAXY)
      window.draw(sprite)
      window.display

      i += 1
      puts "Tic #{i}"
      Fiber.yield
      hw.update
    end
  end
end