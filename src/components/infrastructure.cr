class Curve
  include YAML::Serializable
  property function : String
  property coefs : Hash(String, Float64 | Int32)

  def coef(name : String, default : Float64 = 0.0) : Float64
    @coefs.fetch(name, default).to_f64
  end

  FUNCTIONS = {
    # Proc(Float64, Float64).new { |x| x }
    "linear" => ->(x) { (coef("b", 0.0) + x) * coef("b", 1.0) + coef("c", 0.0) },
  }

  def execute(x : Float64) : Float64
    FUNCTIONS[@function].call(x)
  end
end

class Infrastructure
  BLUEPRINTS = Blueprint.map("infrastructures", filter: /\.yaml$/) { |file| File.open(file) }

  alias Costs = Hash(String, Curve)
  alias Productions = Hash(String, Curve)

  include YAML::Serializable
  include YAML::Serializable::Unmapped
  property max : Int32
  property min : Int32
  property title : String
  property description : String
  property costs : Costs
  property prods : Productions
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

