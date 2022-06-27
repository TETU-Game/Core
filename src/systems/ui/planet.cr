class TETU::UiPlanetSystem
  include Entitas::Systems::ExecuteSystem

  def initialize(@context : GameContext); end

  def execute
    planet = TETU::Window.instance.planet_menu_selected
    return if planet.nil?
    draw_planet(planet)
  end

  private def draw_planet(planet : Entitas::Entity)
    draw_planet_frame do
      ImGui.text planet.named.name

      if planet.has_resources?
        draw_storage planet
        ImGui.text ""
        draw_infras planet
      else
        ImGui.text "Barren..."
      end
    end
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
    if ImGui.begin_table("infra", res_names.size + 2)
      ImGui.table_next_row
      ImGui.table_next_column
      ImGui.text ""
      ImGui.table_next_column
      ImGui.text "Tier"

      res_names.each do |res|
        ImGui.table_next_column
        ImGui.text res
      end

      infras.each_value do |infra|
        draw_one_infra(infra, res_names)
      end

      ImGui.end_table
    end
  end

  private def draw_one_infra(infra, res_names)
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

  private def draw_planet_frame(&block)
    if ImGui.begin(name: "left side", flags: ImGui::ImGuiWindowFlags.new(0))
      ImGui.set_window_pos("left side", ImGui::ImVec2.new(0, 0))
      ImGui.set_window_size("left side", ImGui::ImVec2.new(LEFT_SIDEBAR_SIZE, Window::GALAXY_HEIGHT))
      yield
    end
    ImGui.end
  end


end
