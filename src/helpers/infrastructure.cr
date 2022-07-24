require "./curve"

# Allow to unserialize yaml mods.
# This is supposed to be used for a given tier like:
#
# ```
# costs.map { |res, cost_f| cost_f.execute(new_tier) }
# ```
class TETU::Helpers::Infrastructure
  spoved_logger level: :debug, io: STDOUT, bind: true

  BLUEPRINTS = Blueprint.all("infrastructures", filter: /\.yaml$/)
  Log.debug { { "infra bp": BLUEPRINTS } }

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

  class ManpowerCurves
    include YAML::Serializable
    property min : Curve
    property optimal : Curve
    property max : Curve
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
  property manpower : ManpowerCurves
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
  Log.debug { "Parsing infrastructure blueprint #{blueprint}" }
  TETU::Helpers::InfrastructuresFileLoader.from_yaml(File.open(blueprint)).items.each do |item_id, item|
    item.id = item_id
    TETU::Helpers::InfrastructuresFileLoader.all[item_id] = item
  end
end

