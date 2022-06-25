@[Context(Game)]
class Resources < Entitas::Component
  BLUEPRINTS = Blueprint.map("resources", filter: /\.yaml$/) { |file| File.open(file) }
  DESCRIPTIONS = BLUEPRINTS.map { |b| YAML.parse(b).as_h }.reduce { |l, r| l.merge(r) }
  LIST = DESCRIPTIONS.keys.map(&.as_s)
  # LIST = %i[food food2 mineral mineral2 alloy alloy2 chemical weapon logistic pollution research]
  # LIST_S_TO_SYM = LIST.to_h { |k| Tuple.new(k.to_s, k) }
  alias Name = String

  struct Store
    getter amount, max
    def initialize(@amount : Float64, @max : Float64)
    end
  end

  class Stores < Hash(Name, Store)
  end

  alias Moving = Hash(Name, Store)
  class Prods < Moving
  end

  class Stores < Moving
  end

  struct Infra
    property id : String
    property tier : Int32

    def initialize(@id, @tier = 0)
    end
  end

  class Infras < Hash(Name, Infra)
  end

  prop :prods, Prods
  prop :consumes, Prods
  prop :stores, Stores
  prop :infras, Infras

  def prod_rate
    consumes
      .map { |res, value| stores[res] >= res ? 1.0 : res / stores[res] }
      .min
  end

  def self.default
    stores = Stores.new
    prods = Prods.new
    infras = Infras.new

    LIST.each do |res_name|
      stores[res_name] = Store.new(amount: 0.0, max: 1.0)
    end
    stores["pollution"] = Store.new(amount: 0.0, max: 1_000_000.0)

    Resources.new(stores: stores, prods: prods, infras: infras)
  end

  def self.default_populated
    r = default()
    r.stores["pollution"] = Store.new(amount: 100.0, max: 1_000_000.0) # habitable planet are already polluted a little

    r.upgrade(InfrastructureUpgrade.free_instant(id: "e_store"))
    r.upgrade(InfrastructureUpgrade.free_instant(id: "m_store"))
    r.upgrade(InfrastructureUpgrade.free_instant(id: "f_store"))
    r.upgrade(InfrastructureUpgrade.free_instant(id: "a_store"))
    r.upgrade(InfrastructureUpgrade.free_instant(id: "l_store"))
    r.upgrade(InfrastructureUpgrade.free_instant(id: "e_plant"))
    r.upgrade(InfrastructureUpgrade.free_instant(id: "mine"))
    r.upgrade(InfrastructureUpgrade.free_instant(id: "farm"))
    r.upgrade(InfrastructureUpgrade.free_instant(id: "a_plant"))
    r.upgrade(InfrastructureUpgrade.free_instant(id: "l_plant"))

    r
  end

  def add(resource : Symbol, amount : Number)
    storages[resource] = Store.new(
      amount: storages[resource].amount + amount,
      max: storages[resource].max,
    )
  end

  def to_s
    stores_to_s = storages.map{ |k, v| "#{k}=#{v.amount}/#{v.max}" }.join(" ")
    productions_to_s = productions? ? productions.map { |io, speed| "#{io.input}=>#{io.output}x#{speed.rate}" }.join(" ") : "?"
    "Resources: store{#{stores_to_s}} production={#{productions_to_s}}}"
  end
end
