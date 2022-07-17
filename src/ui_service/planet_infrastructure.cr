class TETU::UiService::PlanetInfrastructure < TETU::UiService
  include Helpers::UiSystem

  def initialize(@planet : GameEntity)
  end

  def draw
    if ImGui.tree_node_ex("resources panel", ImGui::ImGuiTreeNodeFlags.new(ImGui::ImGuiTreeNodeFlags::DefaultOpen))
      draw_resources
      ImGui.tree_pop
    end
  end

  private def draw_resources
    ImGui.text @planet.named.name

    if @planet.has_resources?
      draw_storage
      ImGui.text ""
      draw_infras
    else
      ImGui.text "Barren..."
    end
  end

  private def draw_storage
    stores = @planet.resources.stores
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

  private def draw_infras
    infras = @planet.resources.infras
    res_names = @planet.resources.stores.keys
    headers = [ "", "Tier" ] + res_names + [ "Upgrade" ]
    stores = @planet.resources.stores
    draw_table(title: "infra", headers: headers) do
      stores.each do |res, store|
        Helpers::InfrastructuresFileLoader.all.keys.each do |infra_id|
          infra = infras[infra_id]?
          if infra.nil?
            draw_unconstructed_infra(infra_id, res_names)
          else
            draw_one_infra(infra, res_names)
          end
        end
      end
    end
  end

  private def draw_one_infra(infra, res_names)
    ImGui.table_next_row
    draw_table_cell infra.id
    ImGui.table_next_column
    draw_table_cell infra.tier.to_s

    res_names.each do |res|
      total = infra.prods.fetch(res, 0.0) - infra.consumes.fetch(res, 0.0) + infra.wastes.fetch(res, 0.0)
      draw_table_cell total.to_s
    end

    @planet.add_infrastructure_upgrades if !@planet.has_infrastructure_upgrades?
    Log.debug { { "@planet.infrastructure_upgrades": @planet.infrastructure_upgrades } } if !@planet.infrastructure_upgrades.upgrades.empty?
    draw_table_cell do
      if ImGui.button("upgrade####{infra.id}")
        @planet.infrastructure_upgrades.upgrades << InfrastructureUpgrade.from_blueprint(infra.id, infra.tier + 1)
      end
    end
  end

  private def draw_unconstructed_infra(infra_id, res_names)
    ImGui.table_next_row
    draw_table_cell infra_id
    draw_table_cell "-"

    res_names.each do |res|
      draw_table_cell "-"
    end

    @planet.add_infrastructure_upgrades if !@planet.has_infrastructure_upgrades?
    draw_table_cell do
      if ImGui.button("build####{infra_id}")
        @planet.infrastructure_upgrades.upgrades << InfrastructureUpgrade.from_blueprint(infra_id, 1)
      end
    end
  end

end
