@[Context(Game)]
class Resources < Entitas::Component
  DESCRIPTIONS = Blueprint.load_yaml("resources", "descriptions.yaml").as_h
  LIST = %i[food food2 mineral mineral2 alloy alloy2 chemical weapon logistic pollution research]
  LIST_S_TO_SYM = LIST.to_h { |k| Tuple.new(k.to_s, k) }

  struct Store
    getter amount, max
    def initialize(@amount : Float64, @max : Float64)
    end
  end

  class Stores < Hash(Symbol, Store)
  end

  struct InOut
    getter input, output
    def initialize(@input : Symbol, @output : Symbol)
    end
  end

  struct ProdSpeed
    getter rate, max_speed
    def initialize(@rate : Float64, @max_speed : Float64)
    end
  end

  class Prods < Hash(InOut, ProdSpeed)
  end

  class Infra
  end

  class Infras < Hash(Symbol, Infra)
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
    stores[:pollution] = Store.new(amount: 0.0, max: 1.0)

    Resources.new(storages: stores, productions: prods, infrastructures: infras)
  end

  def self.default_populated
    r = default()
    r.storages[:food]     = Store.new(amount: 0.0, max: 1000.0)
    r.storages[:mineral]  = Store.new(amount: 0.0, max: 10000.0)
    r.storages[:alloy]    = Store.new(amount: 0.0, max: 10000.0)
    r.storages[:logistic] = Store.new(amount: 0.0, max: 10.0)

    # TODO: use InfrastructuresFileLoader.all to load basic infra
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

  def upgrade(upgrade : InfrastructureUpgrades::InfrastructureUpgrade)
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
