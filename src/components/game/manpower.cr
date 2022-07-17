@[Context(Game)]
class TETU::ManpowerAllocation < Entitas::Component
  # this will have { infra_name => 0.2 }
  prop ratio, Hash(String, Float64), default: Hash(String, Float64).new
  prop absolute, Hash(String, Float64), default: Hash(String, Float64).new
  prop fixed, Hash(String, Bool), default: Hash(String, Bool).new
  prop available, Float64, default: 0.0
end
