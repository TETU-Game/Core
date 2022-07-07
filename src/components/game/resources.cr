@[Context(Game)]
class TETU::Resources < Entitas::Component
  BLUEPRINTS = Blueprint.all("resources", filter: /\.yaml$/)
  Log.debug { { "resources bp": BLUEPRINTS } }
  DESCRIPTIONS = BLUEPRINTS.map { |b| YAML.parse(File.open(b)).as_h }.reduce { |l, r| l.merge(r) }
  LIST = DESCRIPTIONS.keys.map(&.as_s)
  # LIST = %i[food food2 mineral mineral2 alloy alloy2 chemical weapon logistic pollution research]
  # LIST_S_TO_SYM = LIST.to_h { |k| Tuple.new(k.to_s, k) }
  alias Name = String

  class Store
    property amount, max
    def initialize(@amount : Float64, @max : Float64)
    end

    def self.empty
      new(amount: 0.0, max: 0.0)
    end

    def humanize
      "#{@amount}/#{@max}"
    end
  end

  class Stores < Hash(Name, Store)
    def humanize(sep = "\n")
      map { |k, store| "#{k}: #{store.humanize}" }.join(sep)
    end
  end

  # alias Prod = Tuple(Name, Float64)
  alias Moving = Hash(Name, Float64)
  class Prods < Moving
  end

  class Infra
    property id : String
    property tier : Int32
    property prods : Prods
    property consumes : Prods
    property wastes : Prods
    # this allow to manipulate the planet (local) store
    # or make a special infrastructure specific store not shared if we want
    getter stores : Stores

    def initialize(@id, @stores, @tier = 0)
      @prods = Prods.new
      @consumes = Prods.new
      @wastes = Prods.new
    end

    def prod_rate : Float64
      return 1.0 if consumes.empty?
      return 0.0 if consumes.any? { |res, _value| stores[res]?.nil? }
      (consumes.map { |res, value| stores[res].amount / value } + [1.0]).min
    end

    def humanize(sep = "\n")
      all_res = (consumes.keys + stores.keys + prods.keys).uniq.sort
      all_res.map do |res|
        store = (stores[res]? || Store.empty)
        consume = consumes[res]? || 0.0
        prod = prods[res]? || 0.0
        "#{res}: #{store.humanize} +#{prod} -#{consume}"
      end.join(sep)
    end
  end

  class Infras < Hash(Name, Infra)
    # getter @stores : Stores
    # def initialize(@stores)
    # end

    def humanize(sep = ", ")
      map { |id, infra| "#{id} (#{infra.tier})" }.join(sep)
    end
  end

  prop :stores, Stores
  prop :infras, Infras

  def can_produce?
    stores? && infras?
  end

  def humanize(sep = "\n")
    infras.humanize(sep)
  end

  def self.default
    stores = Stores.new
    stores["pollution"] = Store.new(amount: 0.0, max: 1_000_000.0)

    infras = Infras.new()

    Resources.new(stores: stores, infras: infras)
  end

  def self.default_populated
    r = default()
    r.stores["pollution"].amount = 100.0 # habitable planet are already polluted a little

    r
  end

  def humanize
    "Resources:#{infras.humanize}"
  end
end
