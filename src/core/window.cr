require "./configuration"

class TETU::Window
  @@instance = Window.new

  def self.instance
    @@instance
  end

  GALAXY_WIDTH = TETU::MAX_X
  GALAXY_HEIGHT = TETU::MAX_Y
  UI_WIDTH = GALAXY_WIDTH + TETU::UI_CONF["right_sidebar"].as_i64
  UI_HEIGHT = GALAXY_HEIGHT
  SQUARE_SIZE = TETU::UI_CONF["square_size"].as_i64

  GALAXY = SF::Texture.from_file("assets/#{GALAXY_WIDTH}x#{GALAXY_HEIGHT}/galaxy.jpg")

  getter window : SF::RenderWindow
  getter delta_clock : SF::Clock
  property planet_menu_selected : GameEntity? = nil

  def initialize()
    @window = SF::RenderWindow.new(
      SF::VideoMode.new(UI_WIDTH, UI_HEIGHT),
      "To the End of The Universe",
    )
    @delta_clock = SF::Clock.new
  end

  def [](k)
    @data[k]
  end
end
