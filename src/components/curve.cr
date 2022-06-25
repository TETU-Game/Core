class Curve
  include YAML::Serializable
  property function : String
  property coefs : Hash(String, Float64 | Int32)

  def coef(name : String, default : Float64 = 0.0) : Float64
    @coefs.fetch(name, default).to_f64
  end

  # NOTE: we should add a "t" to represent the duration of exploitation:
  #       older planets need new investments to keep up with usure
  # Proc(Float64, Tick, Float64).new { |x| x }
  # (x) : the tier of the upgrade
  FUNCTIONS = {
    # a(x + b) + c (constants are a, b, c)
    "linear" => ->(f : Curve, x : Float64, t : TETU::Tick) {
      (f.coef("b", 0.0) + x) * f.coef("b", 1.0) + f.coef("c", 0.0)
    },
    # 1 + 2x + 3x² + 4x³ + ... (constants to define are 1, 2, 3, 4, ...)
    "polynome" => ->(f : Curve, x : Float64, t : TETU::Tick) {
      coef_ordered = f.coefs.keys.sort
      return 0.0 if coef_ordered.empty?
      index = 0
      coef_ordered[1..-1].reduce(f.coef(coef_ordered.first)) do |base, coef|
        index += 1
        base + x ** index
      end
    },
    # log[a](x + b)*c + d (constants are a, b, c, d)
    "log" => ->(f : Curve, x : Float64, t : TETU::Tick) {
      Math.log(f.coef("b", 10.0) + x, f.coef("a", 2.0)) * f.coef("c", 1.0) + f.coef("d", 0.0)
    },
    # (a^x)b + c (constants are a, b, c)
    "squared" => ->(f : Curve, x : Float64, t : TETU::Tick) {
      (x ** f.coef("a", 1.0)) * f.coef("b", 1.0) + f.coef("c", 0.0)
    },
  }

  def execute(x : Float64, t : TETU::Tick = 0) : Float64
    f = FUNCTIONS.fetch(@function) { raise "Invalid \"#{@function}\" name for function type. Valids are #{FUNCTIONS.keys.join(", ")}" }
    f.call(self, x, t)
  end
end
