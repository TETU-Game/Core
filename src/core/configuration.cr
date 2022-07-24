require "yaml"

class TETU::Configuration
  @@instance = Configuration.new("configuration.yaml")

  def self.instance
    @@instance
  end

  @data : YAML::Any

  def initialize(file_path : String)
    @data = YAML.parse(File.read(file_path))
  end

  def [](k)
    @data[k]
  end
end

module TETU
  CONF = TETU::Configuration.instance

  MAX_X = CONF["max_x"].as_i
  MAX_Y = CONF["max_y"].as_i

  GALAXY_CONF = TETU::CONF["galaxy"]
  UI_CONF     = TETU::CONF["ui"]

  alias Tick = Int64
  # struct Tick
  # end
end
