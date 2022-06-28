require "./curve"

# Allow to unserialize yaml mods.
# This is supposed to be used for a given tier like:
#
# ```
# costs.map { |res, cost_f| cost_f.execute(new_tier) }
# ```
class TETU::Helpers::Infrastructure
  BLUEPRINTS = Blueprint.all("infrastructures", filter: /\.yaml$/)
  pp "infra bp", BLUEPRINTS

  # alias Costs = Hash(String, Curve)
  # alias Productions = Hash(String, Curve)
  # alias Stores = Hash(String, Curve)
  alias ResourceCurves = Hash(String, Curve)
  class Build
    include YAML::Serializable
    property upfront : Float64
    property duration : Curve
    property costs : ResourceCurves
  end

  include YAML::Serializable
  include YAML::Serializable::Unmapped
  property max : Int32 = -1
  property min : Int32 = -1
  property title : String = "?"
  property description : String = "?"
  property build : Build
  property prods : ResourceCurves
  property consumes : ResourceCurves
  property wastes : ResourceCurves
  property stores : ResourceCurves
  property id : String = ""
end

class TETU::Helpers::InfrastructuresFileLoader
  include YAML::Serializable
  include YAML::Serializable::Unmapped
  property items : Hash(String, Infrastructure)
  property templates : YAML::Any

  @@all = Hash(String, Infrastructure).new
  def self.all
    @@all
  end
end

TETU::Helpers::Infrastructure::BLUEPRINTS.each do |blueprint|
  puts "Parsing infrastructure blueprint #{blueprint}"
  TETU::Helpers::InfrastructuresFileLoader.from_yaml(File.open(blueprint)).items.each do |item_id, item|
    item.id = item_id
    TETU::Helpers::InfrastructuresFileLoader.all[item_id] = item
  end
end

