class TETU::Helpers::Planet
  # keep it low and > 0 for dev
  # else we can go 0..max and use a stat function for high 2-3 systems
  BODIES_STATISTICS = (1..TETU::GALAXY_CONF["max_bodies_by_system_amount"].as_i)

  # TODO don't copy symbols like this, use constants instead
  TYPES_STATISTICS = %i(asteroid_belt planet planet planet)

  # keep it low for dev
  MOONS_STATISTICS = (0..TETU::GALAXY_CONF["max_moon_by_planet_amount"].as_i)
end
