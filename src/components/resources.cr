@[Context(Game)]
class Resources < Entitas::Component
  BLUEPRINTS = Blueprint.all("resources", filter: /\.yaml$/)
  pp "resources bp", BLUEPRINTS
  DESCRIPTIONS = BLUEPRINTS.map { |b| YAML.parse(File.open(b)).as_h }.reduce { |l, r| l.merge(r) }
  LIST = DESCRIPTIONS.keys.map(&.as_s)
  # LIST = %i[food food2 mineral mineral2 alloy alloy2 chemical weapon logistic pollution research]
  # LIST_S_TO_SYM = LIST.to_h { |k| Tuple.new(k.to_s, k) }
  alias Name = String

  class Store
    property amount, max
    def initialize(@amount : Float64, @max : Float64)
    end
  end

  class Stores < Hash(Name, Store)
  end

  # alias Prod = Tuple(Name, Float64)
  alias Moving = Hash(Name, Float64)
  class Prods < Moving
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

  def can_produce?
    consumes? && prods? && stores? && infras?
  end

  def prod_rate : Float64
    return 1.0 if consumes.empty?
    consumes
      .map { |res, value| stores[res].amount >= value ? 1.0 : value / stores[res].amount }
      .min
  end

  def self.default
    stores = Stores.new
    prods = Prods.new
    infras = Infras.new
    consumes = Prods.new

    LIST.each do |res_name|
      stores[res_name] = Store.new(amount: 0.0, max: 1.0)
    end
    stores["pollution"] = Store.new(amount: 0.0, max: 1_000_000.0)

    Resources.new(stores: stores, prods: prods, infras: infras, consumes: consumes)
  end

  def self.default_populated
    r = default()
    r.stores["pollution"] = Store.new(amount: 100.0, max: 1_000_000.0) # habitable planet are already polluted a little

    r
  end

  def to_s
    stores_to_s = stores.map{ |k, v| "#{k}=#{v.amount}/#{v.max}" }.join(" ")
    productions_to_s = prods.map { |res, value| "#{res}=#{value}" }.join(" ")
    consumes_to_s = prods.map { |res, value| "#{res}=#{value}" }.join(" ")
    "Resources:\n\tstore{#{stores_to_s}}\n\tconsumes={#{consumes_to_s}}\n\tproduces={#{productions_to_s}}"
  end
end
