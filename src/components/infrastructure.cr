require "./curve"

class Infrastructure
  BLUEPRINTS = Blueprint.all("infrastructures", filter: /\.yaml$/)
  pp "infra bp", BLUEPRINTS

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
  property build : { start: Float64, duration: Curve }
  property costs : ResourceCurves
  property prods : ResourceCurves
  property consumes : ResourceCurves
  property stores : ResourceCurves
  property id : String = ""
end

class InfrastructuresFileLoader
  include YAML::Serializable
  include YAML::Serializable::Unmapped
  property items : Hash(String, Infrastructure)
  property templates : YAML::Any

  @@all = Hash(String, Infrastructure).new
  def self.all
    @@all
  end
end

Infrastructure::BLUEPRINTS.each do |blueprint|
  puts "Parsing infrastructure blueprint #{blueprint}"
  InfrastructuresFileLoader.from_yaml(File.open(blueprint)).items.each do |item_id, item|
    item.id = item_id
    InfrastructuresFileLoader.all[item_id] = item
  end
end

