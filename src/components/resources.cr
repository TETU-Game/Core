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

  struct InOut
    getter input, output
    def initialize(@input : Name, @output : Name)
    end
  end

  struct ProdSpeed
    getter rate, max_speed
    def initialize(@rate : Float64, @max_speed : Float64)
    end
  end

  class Prods < Hash(InOut, ProdSpeed)
  end

  struct Infra
    property id : String
    property tier : Int32

    def initialize(@id, @tier = 0)
    end
  end

  class Infras < Hash(Name, Infra)
  end

  prop :productions, Prods
  prop :storages, Stores
  prop :infrastructures, Infras

  def self.default
    stores = Stores.new
    prods = Prods.new
    infras = Infras.new

    LIST.each do |res_name|
      stores[res_name] = Store.new(amount: 0.0, max: 1.0)
    end
    stores["pollution"] = Store.new(amount: 0.0, max: 1_000_000.0)

    Resources.new(storages: stores, productions: prods, infrastructures: infras)
  end

  def self.default_populated
    r = default()
    # r.storages[:food]      = Store.new(amount: 0.0, max: 1000.0)
    # r.storages[:mineral]   = Store.new(amount: 0.0, max: 10000.0)
    # r.storages[:alloy]     = Store.new(amount: 0.0, max: 10000.0)
    # r.storages[:logistic]  = Store.new(amount: 0.0, max: 10.0)
    r.storages["pollution"] = Store.new(amount: 100.0, max: 1_000_000.0) # habitable planet are already polluted a little

    # TODO
    # r.upgrade(InfrastructureUpgrade.new(id: "e_plan", costs_by_tick: ))

    # r.productions[InOut.new(input: :nil, output: :food)] = ProdSpeed.new(rate: 1.0, max_speed: 20.0)
    # r.productions[InOut.new(input: :nil, output: :mineral)] = ProdSpeed.new(rate: 1.0, max_speed: 10.0)
    # r.productions[InOut.new(input: :mineral, output: :alloy)] = ProdSpeed.new(rate: 1.0, max_speed: 1.0)
    # r.productions[InOut.new(input: :alloy, output: :weapon)] = ProdSpeed.new(rate: 0.1, max_speed: 0.1)
    # r.productions[InOut.new(input: :alloy, output: :logistic)] = ProdSpeed.new(rate: 0.1, max_speed: 0.1)
    r
  end

  def self.required_input(prod_speed : ProdSpeed)
    prod_speed.max_speed. / prod_speed.rate
  end

  def add(resource : Symbol, amount : Number)
    storages[resource] = Store.new(
      amount: storages[resource].amount + amount,
      max: storages[resource].max,
    )
  end

  def upgrade(upgrade : InfrastructureUpgrade)
    # resource = upgrade[:resource]
    # upgrade[:costs].each do |cost_resource, cost_amount|
    #   add cost_resource, -cost_amount
    # end
    # storages[resource] = {
    #   amount: storages[resource][:amount],
    #   max: storages[resource][:max] + upgrade[:storages][:max],
    # }
  end

  def to_s
    stores_to_s = storages.map{ |k, v| "#{k}=#{v.amount}/#{v.max}" }.join(" ")
    productions_to_s = productions? ? productions.map { |io, speed| "#{io.input}=>#{io.output}x#{speed.rate}" }.join(" ") : "?"
    "Resources: store{#{stores_to_s}} production={#{productions_to_s}}}"
  end
end
