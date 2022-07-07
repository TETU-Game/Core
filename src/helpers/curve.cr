class TETU::Helpers::Curve
  include YAML::Serializable
  property function : String
  property coefs : Hash(String, Float64 | Int32)

  def coef(name : String, default : Float64 = 0.0) : Float64
    @coefs.fetch(name, default).to_f64
  end

  # Proc(Float64, Tick, Float64).new { |x| x }
  # (x) : the tier of the upgrade
  FUNCTIONS = {
    # = x (any constant name is accepted, only one)
    "constant" => ->(f : Curve, x : Float64, t : TETU::Tick) {
      f.coefs.values.first.to_f64
    },
    # a(x + b) + c (constants are a, b)
    "linear" => ->(f : Curve, x : Float64, t : TETU::Tick) {
      x * f.coef("a", 1.0) + f.coef("b", 0.0)
    },
    # ax⁰ + bx¹ + cx² + dx³ + ... (constants to define are alpha order)
    "polynome" => ->(f : Curve, x : Float64, t : TETU::Tick) {
      coef_ordered = f.coefs.keys.sort
      return 0.0 if coef_ordered.empty?
      index = 0
      coef_ordered[1..-1].reduce(f.coef(coef_ordered.first)) do |base, coef|
        index += 1
        base + coef.to_f64 * (x ** index)
      end
    },
    # log[base](x + b)*c + d (constants are a, base, b, c)
    "log" => ->(f : Curve, x : Float64, t : TETU::Tick) {
      Math.log(f.coef("base", 2.0), x + f.coef("b", 2.0)) * f.coef("a", 1.0) + f.coef("c", 0.0)
    },
    # (a^x)b + c (constants are a, base, b, c)
    "squared" => ->(f : Curve, x : Float64, t : TETU::Tick) {
      (x + f.coef("b", 2.0)) ** f.coef("base", 2.0) * f.coef("a", 1.0) + f.coef("c", 0.0)
    },
  }

  def execute(x : Float64, t : TETU::Tick = 0) : Float64
    f = FUNCTIONS.fetch(@function) { raise "Invalid \"#{@function}\" name for function type. Valids are #{FUNCTIONS.keys.join(", ")}" }
    f.call(self, x, t)
  end
end
