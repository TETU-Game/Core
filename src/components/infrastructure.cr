class Curve
  include YAML::Serializable
  property function : String
  property coefs : Hash(String, Float64 | Int32)

  def coef(name : String, default : Float64 = 0.0) : Float64
    @coefs.fetch(name, default).to_f64
  end

  # NOTE: we should add a "t" to represent the duration of exploitation:
  #       older planets need new investments to keep up with usure
  # Proc(Float64, Float64).new { |x| x }
  # (x) : the tier of the upgrade
  FUNCTIONS = {
    # a(x + b) + c (constants are a, b, c)
    "linear" => ->(x) { (coef("b", 0.0) + x) * coef("b", 1.0) + coef("c", 0.0) },
    # 1 + 2x + 3x² + 4x³ + ... (constants to define are 1, 2, 3, 4, ...)
    "polynome" => ->(x) {
      coef_ordered = coefs.keys.sort
      return 0.0 if coef_ordered.empty?
      index = 0
      coef_ordered[1..-1].reduce(coefs(coef_ordered.first)) do |base, coef|
        index += 1
        base + x ** index
      end
    },
    # log[a](x + b)*c + d (constants are a, b, c, d)
    "log" => ->(x) { Math.log(coef("b", 10.0) + x, coef("a", 2.0)) * coef("c", 1.0) + coef("d", 0.0) },
    # (a^x)b + c (constants are a, b, c)
    "squared" => ->(x) { (x ** coef("a", 1.0)) * coef("b", 1.0) + coef("c", 0.0) },
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

