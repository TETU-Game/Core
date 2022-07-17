class TETU::UiService::PlanetManpower < TETU::UiService
  include Helpers::UiSystem

  def initialize(@planet : GameEntity)
  end

  def draw
    if ImGui.tree_node_ex(
        "manpower panel",
        ImGui::ImGuiTreeNodeFlags.new(ImGui::ImGuiTreeNodeFlags::DefaultOpen),
      )
      draw_main_table
      ImGui.tree_pop
    end
  end

  def draw_main_table
    draw_table(title: "manpower", headers: {"Infra", "Ajust", "Lock"}) do
      infras = @planet.resources.infras
      stores = @planet.resources.stores
      Helpers::InfrastructuresFileLoader.all.keys.each do |infra_id|
        infra = infras[infra_id]?
        draw_infra_line(infra) if infra
      end
    end
  end

  def draw_infra_line(infra : Resources::Infra)
    if !@planet.manpower_allocation.absolute.has_key?(infra.id)
      @planet.manpower_allocation.absolute[infra.id] = 0.0
    end

    v = @planet.manpower_allocation.absolute[infra.id].to_f32
    ptr = pointerof(v)

    draw_table_line(
      infra.id,
      -> {
        # TODO: we can use SliderScalar for Double (float64)
        if ImGui.slider_float(
            label: "absolute####{infra.id}",
            v: ptr,
            v_min: 0.0.to_f32,
            v_max: @planet.manpower_allocation.available.to_f32,
            flags: (
              ImGui::ImGuiSliderFlags::NoRoundToFormat |
              ImGui::ImGuiSliderFlags::Logarithmic
            ),
          )
          Log.debug { "set #{infra.id} absolute manpower to #{v} because " }
          @planet.manpower_allocation.available += @planet.manpower_allocation.absolute[infra.id]
          @planet.manpower_allocation.available -= v
          @planet.manpower_allocation.absolute[infra.id] = v
        end
      },
      "[lock]",
    )
  end
end
