require "./curve"

class Infrastructure
  BLUEPRINTS = Blueprint.map("infrastructures", filter: /\.yaml$/) { |file| File.open(file) }

  # alias Costs = Hash(String, Curve)
  # alias Productions = Hash(String, Curve)
  # alias Stores = Hash(String, Curve)
  alias ResourceCurves = Hash(String, Curve)

  include YAML::Serializable
  include YAML::Serializable::Unmapped
  property max : Int32 = -1
  property min : Int32 = -1
  property title : String = "?"
  property description : String = "?"
  property costs : ResourceCurves
  property prods : ResourceCurves
  property stores : ResourceCurves
  property build : { start: Float64, duration: Curve }
  property id : String = ""
end

class InfrastructuresFileLoader
  include YAML::Serializable
  include YAML::Serializable::Unmapped
  property items : Hash(String, Infrastructure)
  property templates : YAML::Any

  @@all = [] of Infrastructure
  def self.all
    @@all
  end
end

Infrastructure::BLUEPRINTS.each do |blueprint|
  InfrastructuresFileLoader.from_yaml(blueprint).items.each do |item_id, item|
    item.id = item_id
    InfrastructuresFileLoader.all << item
  end
end

