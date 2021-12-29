class GalaxyInitializerSystem
  include Entitas::Systems::InitializeSystem

  def initialize(@context : GameContext); end

  SYSTEMS_AMOUNT = TETU::GALAXY_CONF["systems_amount"].as_i64

  def init
    stars = SYSTEMS_AMOUNT.times.map do |i|
      generate_star
    end.to_a
    stars = @context.get_group Entitas::Matcher.all_of(Named, Position, CelestialBody).none_of(StellarPosition)
    stars.entities.each { |entity| puts "new Star [#{entity.named.to_s}] at [#{entity.position.to_s}]" }

    bodies = @context.get_group Entitas::Matcher.all_of(Named, Position, CelestialBody, StellarPosition)
    bodies.entities.each { |entity| puts "new Body [#{entity.named.to_s}] in [#{entity.stellar_position.body_index}, #{entity.stellar_position.moon_index}]" }
  end

  private def generate_star
    ids_trash = {
      :asteroid_belt => 0,
      :planet        => 0,
      :moon          => 0,
    }
    
    star = @context.create_entity
    star.add_celestial_body type: :star
    star.add_show_state gui: true, resources: false
    Position.generate star
    Named.generate_star star
    
    bodies_amount = Planet::BODIES_STATISTICS.sample
    bodies_amount.times.map do |index|
      body_type = Planet::TYPES_STATISTICS.sample
      ids_trash[body_type] += 1
      body = generate_body(star: star, index: index, body_type: body_type, ids_trash: ids_trash)
      if body_type == :asteroid_belt
        body_to_asteroid_belt(star: star, body: body, index: index, body_index: ids_trash[body_type])
      else
        body_to_planet(star: star, body: body, index: index, body_index: ids_trash[body_type])
      end
    end.to_a
  end

  private def generate_body(star : Entitas::IEntity, index : Int32, body_type : Symbol, ids_trash : Hash(Symbol, Int32))
    star_position = star.position

    body = @context.create_entity
    body.add_show_state gui: true, resources: false
    star_position.as(Position).copy_to body
    body.add_stellar_position body_index: index, moon_index: ids_trash[:moon]

    body.add_celestial_body type: body_type
    body
  end

  private def body_to_planet(star, body, index, body_index, moon_index = nil)
    star_name = star.named.name
    moon_particule = moon_index ? ("a".."z").to_a[moon_index] : ""
    body.add_named name: "#{star_name} #{body_index}#{moon_particule}"
    if moon_index.nil?
      moon_amount = Planet::MOONS_STATISTICS.sample
      moon_amount.times.map do |moon_time_index|
        ids_trash_with_moon = {
          :asteroid_belt => 0,
          :planet        => 0,
          :moon          => moon_time_index + 1,
        }
        moon_body = generate_body(star: star, index: index, body_type: :planet, ids_trash: ids_trash_with_moon)
        body_to_planet(star: star, body: moon_body, index: index, body_index: body_index, moon_index: moon_time_index + 1)
        moon_body
      end.to_a
    end

    populate(body) if rand < TETU::GALAXY_CONF["populated_planets_proba"].as_f
    body
  end

  private def body_to_asteroid_belt(star, body, index, body_index)
    star_name = star.named.name
    body.add_named name: "#{star_name} Belt #{body_index}"
    body
  end

  def populate(body)
    pop_amount = ((10_000.0)..(10_000_000_000.0)).sample
    body.add_population amount: pop_amount
    body.add_resources(
      storages: {
        :food => { amount: 0.0, max: 1000.0 },
        :mineral => { amount: 0.0, max: 10000.0 },
        :alloy => { amount: 0.0, max: 1000.0 },
      },
      productions: {
        { input: nil, output: :food } => { rate: 1.0, max_speed: 20.0 },
        { input: nil, output: :mineral } => { rate: 1.0, max_speed: 10.0 },
        { input: :mineral, output: :alloy } => { rate: 0.2, max_speed: 1.0 },
      },
    )
    body
  end
end
