class TETU::UiPlanetSystem
  include Entitas::Systems::ExecuteSystem

  def initialize(@context : GameContext); end

  def execute
    planet = TETU::Window.instance.planet_menu_selected
    return if planet.nil?
    draw_planet(planet)
  end

  # NOTE: this is a weird pattern, maybe stick to not parameterize the panels?
  private def draw_planet(planet : GameEntity)
    draw_planet_frame(planet, ->draw_resources(GameEntity), ->draw_manpower(GameEntity))
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

  private def draw_manpower(planet : GameEntity)
    ImGui.text "draw manpower"
  end

  private def draw_storage(planet)
    stores = planet.resources.stores
    if ImGui.begin_table("storage", 3)
      ImGui.table_next_row
      ImGui.table_next_column
      ImGui.text ""
      ImGui.table_next_column
      ImGui.text "Amount"
      ImGui.table_next_column
      ImGui.text "Maximum"

      stores.each do |res, store|
        next if store.amount < 0.01

        ImGui.table_next_row
        ImGui.table_next_column
        ImGui.text res
        ImGui.table_next_column
        ImGui.text Helpers::Numbers.humanize(number: store.amount, round: 2)
        ImGui.table_next_column
        ImGui.text Helpers::Numbers.humanize(number: store.max, round: 0)
      end
      ImGui.end_table
    end
  end

  private def draw_infras(planet)
    infras = planet.resources.infras
    res_names = planet.resources.stores.keys
    if ImGui.begin_table("infra", res_names.size + 3)
      ImGui.table_next_row
      ImGui.table_next_column
      ImGui.text ""
      ImGui.table_next_column
      ImGui.text "Tier"

      res_names.each do |res|
        ImGui.table_next_column
        ImGui.text res
      end

      ImGui.table_next_column
      ImGui.text "upgrade"

      Helpers::InfrastructuresFileLoader.all.keys.each do |infra_id|
        infra = infras[infra_id]?
        if infra.nil?
          draw_unconstructed_infra(planet, infra_id, res_names)
        else
          draw_one_infra(planet, infra, res_names)
        end
      end

      ImGui.end_table
    end
  end

  private def draw_one_infra(planet, infra, res_names)
    ImGui.table_next_row
    ImGui.table_next_column
    ImGui.text infra.id
    ImGui.table_next_column
    ImGui.text infra.tier.to_s

    res_names.each do |res|
      total = infra.prods.fetch(res, 0.0) - infra.consumes.fetch(res, 0.0) + infra.wastes.fetch(res, 0.0)
      ImGui.table_next_column
      ImGui.text total.to_s
    end

    ImGui.table_next_column
    planet.add_infrastructure_upgrades if !planet.has_infrastructure_upgrades?
    Log.debug { { "planet.infrastructure_upgrades": planet.infrastructure_upgrades } }
    if ImGui.button("upgrade####{infra.id}")
      planet.infrastructure_upgrades.upgrades << InfrastructureUpgrade.from_blueprint(infra.id, infra.tier + 1)
    end
  end

  private def draw_unconstructed_infra(planet, infra_id, res_names)
    ImGui.table_next_row
    ImGui.table_next_column
    ImGui.text infra_id
    ImGui.table_next_column
    ImGui.text "-"

    res_names.each do |res|
      ImGui.table_next_column
      ImGui.text "-"
    end

    ImGui.table_next_column
    planet.add_infrastructure_upgrades if !planet.has_infrastructure_upgrades?
    if ImGui.button("build####{infra_id}")
      planet.infrastructure_upgrades.upgrades << InfrastructureUpgrade.from_blueprint(infra_id, 1)
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

  private def draw_planet_frame(planet, infra_ui, manpower_ui)
    if ImGui.begin(name: "left side", flags: ImGui::ImGuiWindowFlags.new(0))
      ImGui.set_window_pos("left side", ImGui::ImVec2.new(0, 0))
      ImGui.set_window_size("left side", ImGui::ImVec2.new(LEFT_SIDEBAR_SIZE, Window::GALAXY_HEIGHT))
      if ImGui.tree_node_ex("resources panel", ImGui::ImGuiTreeNodeFlags.new(ImGui::ImGuiTreeNodeFlags::DefaultOpen))
        infra_ui.call(planet)
        ImGui.tree_pop
      end
      if ImGui.tree_node_ex("manpower panel", ImGui::ImGuiTreeNodeFlags.new(ImGui::ImGuiTreeNodeFlags::DefaultOpen))
        manpower_ui.call(planet)
        ImGui.tree_pop
      end
    end
    ImGui.end
  end


end
