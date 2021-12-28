class Planet
  # keep it low and > 0 for dev
  # else we can go 0..max and use a stat function for high 2-3 systems
  BODIES_STATISTICS = (1..TETU::MAX_GENERATED_BODIES_BY_SYSTEM_AMOUNT)

  # TODO don't copy symbols like this, use constants instead
  TYPES_STATISTICS = %i(asteroid_belt planet planet planet)

  # keep it low for dev
  MOONS_STATISTICS = (0..TETU::MAX_GENERATED_MOON_BY_BODY_AMOUNT)
end
