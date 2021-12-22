class Planet
  BODIES_STATISTICS = (0..10)

  # TODO don't copy symbols like this
  TYPES_STATISTICS = %i(asteroid_belt planet planet planet)

  def self.generate(context : GameContext, star : Entitas::IEntity)
    # star_name = star.get_component Named.index_val
    # star_position = star.get_component Position.index_val
    star_name = star.named.name
    star_position = star.position

    bodies_amount = BODIES_STATISTICS.sample
    asteroid_belt_id = 0
    planet_id = 0
    bodies = bodies_amount.times.map do |index|
      body = context.create_entity
      star_position.as(Position).copy_to body
      body.add_stellar_position body_index: index + 1, moon_index: 0
      # TODO add moon generator

      body_type = TYPES_STATISTICS.sample
      body.add_celestial_body type: body_type

      populated_proba = 0.0
      if body_type == :asteroid_belt
        asteroid_belt_id += 1
        body.add_named name: "#{star_name} Belt #{asteroid_belt_id}"
      else
        planet_id += 1
        populated_proba = 0.3
        body.add_named name: "#{star_name} #{planet_id}"
      end

      pop_amount = 0.0
      if rand > populated_proba
        pop_amount = ((10_000.0)..(10_000_000_000.0)).sample
      end
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
          { input: :mineral, output: :alloy } => { rate: 0.2, max_speed: 2.0 },
        },
      )
    end.to_a
  end
end
