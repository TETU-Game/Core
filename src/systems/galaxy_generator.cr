class TETU::GalaxyInitializerSystem
  include Entitas::Systems::InitializeSystem
  spoved_logger level: :info, io: STDOUT, bind: true

  def initialize(@context : GameContext); end

  SYSTEMS_AMOUNT   = GALAXY_CONF["systems_amount"].as_i
  AI_AMOUNT        = GALAXY_CONF["ai_start_amount"].as_i
  EMPIRE_AMOUNT    = AI_AMOUNT + 1 # add the player
  AI_MIN_PLANETS   = GALAXY_CONF["ai_start_populated_bodies_amount"].as_i
  PLANET_POP_PROBA = TETU::GALAXY_CONF["populated_planets_proba"].as_f
  # NO_SPACE_EMPIRE_ID = 100001

  def init
    stars = SYSTEMS_AMOUNT.times.map do |i|
      empire_id = i < EMPIRE_AMOUNT ? i : nil
      star = generate_star(empire_id)
      star.add_player_owned if i == 0
      generate_star_system(star, empire_id)

      star
    end.to_a

    stars = @context.get_group Entitas::Matcher.all_of(Named, Position, CelestialBody).none_of(StellarPosition)
    stars.entities.each { |entity| logger.debug { "new Star [#{entity.named.to_s}] at [#{entity.position.to_s}]" } }
    bodies = @context.get_group Entitas::Matcher.all_of(Named, Position, CelestialBody, StellarPosition)
    bodies.entities.each { |entity| logger.debug { "new Body [#{entity.named.to_s}] in [#{entity.stellar_position.body_index}, #{entity.stellar_position.moon_index}]" } }
  end

  private def generate_star(empire_id : Int32?)
    star = @context.create_entity
    star.add_celestial_body type: :star
    star.add_owned empire_id: empire_id if !empire_id.nil?
    Position.generate star
    Named.generate_star star
  end

  private def generate_star_system(star : Entitas::IEntity, empire_id : Int32?)
    ids_trash = {
      :asteroid_belt => 0,
      :planet        => 0,
      :moon          => 0,
    }

    bodies_amount = Helpers::Planet::BODIES_STATISTICS.sample
    bodies_amount = AI_MIN_PLANETS if !empire_id.nil? && bodies_amount < AI_MIN_PLANETS

    bodies_amount.times.map do |index|
      body_type = Helpers::Planet::TYPES_STATISTICS.sample
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
    star_position.as(Position).copy_to body
    body.add_stellar_position body_index: index, moon_index: ids_trash[:moon]

    body.add_celestial_body type: body_type
    body
  end

  private def body_to_planet(star, body, index, body_index, moon_index = nil)
    star_name = star.named.name
    moon_particule = moon_index ? ("a".."z").to_a[moon_index] : ""
    body.add_named name: "#{star_name} #{body_index}#{moon_particule}"
    body.add_component Resources.default

    if moon_index.nil?
      moon_amount = Helpers::Planet::MOONS_STATISTICS.sample
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

    body.add_player_owned if star.has_player_owned?
    if star.has_owned?
      body.add_owned(empire_id: star.owned.empire_id)
      populate(body) if index < AI_MIN_PLANETS || rand < PLANET_POP_PROBA
    else
      populate(body) if rand < PLANET_POP_PROBA
    end
    body
  end

  private def body_to_asteroid_belt(star, body, index, body_index)
    star_name = star.named.name
    body.add_named name: "#{star_name} Belt #{body_index}"
    body
  end

  DEFAULT_INFRASTRUCTURES = %w[e_store m_store f_store e_plant mine farm a_store l_store a_plant l_plant]

  def populate(body)
    # logger.debug { "populate: #{body.named.name}..." }
    pop_amount = ((10_000.0)..(10_000_000_000.0)).sample
    body.add_population amount: pop_amount
    body.replace_component(Resources.default_populated)
    body.add_infrastructure_upgrades
    body.add_manpower_allocation
    body.manpower_allocation.available = body.population.amount
    DEFAULT_INFRASTRUCTURES.each do |infra_id|
      upgrade = InfrastructureUpgrade.free_instant(id: infra_id)
      body.infrastructure_upgrades.upgrades << upgrade
    end
    # logger.debug { "populated: #{body.named.name}, now #{body.resources.to_s}, with #{body.infrastructure_upgrades.upgrades.size} upgrade to do..." }
    body
  end
end
