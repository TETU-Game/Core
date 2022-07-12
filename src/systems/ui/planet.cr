class TETU::UiPlanetSystem
  Log = TETU::Systems::Log.for(self)

  include Entitas::Systems::ExecuteSystem
  include Helpers::UiSystem

  def initialize(@context : GameContext); end

  def execute
    planet = TETU::Window.instance.planet_menu_selected
    return if planet.nil?
    draw_planet(planet)
  end

  # NOTE: this is a weird pattern, maybe stick to not parameterize the panels?
  private def draw_planet(planet : GameEntity)
    draw_planet_frame(planet, ->draw_resources(GameEntity))
  end

  private def draw_resources(planet : GameEntity)
    ImGui.text planet.named.name

    if planet.has_resources?
      draw_storage planet
      ImGui.text ""
      draw_infras planet
    else
      ImGui.text "Barren..."
    end
  end

  private def draw_storage(planet)
    stores = planet.resources.stores
    draw_table(title: "storage", headers: {"", "Amount", "Maximum"}) do
      stores.each do |res, store|
        next if store.amount < 0.01
        draw_table_line(
          res,
          Helpers::Numbers.humanize(number: store.amount, round: 2),
          Helpers::Numbers.humanize(number: store.max, round: 0),
        )
      end
    end
  end

  private def draw_infras(planet)
    infras = planet.resources.infras
    res_names = planet.resources.stores.keys
    headers = [ "", "Tier" ] + res_names + [ "Upgrade" ]
    stores = planet.resources.stores
    draw_table(title: "infra", headers: headers) do
      stores.each do |res, store|
        Helpers::InfrastructuresFileLoader.all.keys.each do |infra_id|
          infra = infras[infra_id]?
          if infra.nil?
            draw_unconstructed_infra(planet, infra_id, res_names)
          else
            draw_one_infra(planet, infra, res_names)
          end
        end
      end
    end
  end

  private def draw_one_infra(planet, infra, res_names)
    ImGui.table_next_row
    draw_table_cell infra.id
    ImGui.table_next_column
    draw_table_cell infra.tier.to_s

    res_names.each do |res|
      total = infra.prods.fetch(res, 0.0) - infra.consumes.fetch(res, 0.0) + infra.wastes.fetch(res, 0.0)
      draw_table_cell total.to_s
    end

    planet.add_infrastructure_upgrades if !planet.has_infrastructure_upgrades?
    Log.debug { { "planet.infrastructure_upgrades": planet.infrastructure_upgrades } } if !planet.infrastructure_upgrades.upgrades.empty?
    draw_table_cell do
      if ImGui.button("upgrade####{infra.id}")
        planet.infrastructure_upgrades.upgrades << InfrastructureUpgrade.from_blueprint(infra.id, infra.tier + 1)
      end
    end
  end

  private def draw_unconstructed_infra(planet, infra_id, res_names)
    ImGui.table_next_row
    draw_table_cell infra_id
    draw_table_cell "-"

    res_names.each do |res|
      draw_table_cell "-"
    end

    planet.add_infrastructure_upgrades if !planet.has_infrastructure_upgrades?
    draw_table_cell do
      if ImGui.button("build####{infra_id}")
        planet.infrastructure_upgrades.upgrades << InfrastructureUpgrade.from_blueprint(infra_id, 1)
      end
    end
  end

  # ImGui.same_line
  # can_upgrade = resources.storages[:mineral][:amount] >= UPGRADE_MINERAL_COST
  # ImGui.begin_disabled if !can_upgrade
  # if ImGui.button("upgrade####{res}")
  #   # can be written
  #   # # planet.add_resources_upgrades if !planet.has_component? ResourcesUpgrades.index_val
  #   planet.add_resources_upgrades if !planet.has_resources_upgrades?
  #   planet.resources_upgrades.upgrades << {
  #     resource: res,
  #     storages: { max: 1000.0 },
  #     costs: { :mineral => UPGRADE_MINERAL_COST },
  #   }
  # end
  # ImGui.end_disabled if !can_upgrade


  LEFT_SIDEBAR_SIZE = TETU::UI_CONF["left_sidebar"].as_i64

  private def draw_planet_frame(planet, infra_ui)
    manpower_ui = UiService::PlanetManpower.new(planet)
    if ImGui.begin(name: "left side", flags: ImGui::ImGuiWindowFlags.new(0))
      ImGui.set_window_pos("left side", ImGui::ImVec2.new(0, 0))
      ImGui.set_window_size("left side", ImGui::ImVec2.new(LEFT_SIDEBAR_SIZE, Window::GALAXY_HEIGHT))
      if ImGui.tree_node_ex("resources panel", ImGui::ImGuiTreeNodeFlags.new(ImGui::ImGuiTreeNodeFlags::DefaultOpen))
        infra_ui.call(planet)
        ImGui.tree_pop
      end
      manpower_ui.draw
    end
    ImGui.end
  end


end
