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