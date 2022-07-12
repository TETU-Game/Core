module TETU::Helpers::UiSystem
  def window
    TETU::Window.instance.window
  end

  def delta_clock
    TETU::Window.instance.delta_clock
  end

  def draw_table(title : String, headers, &block)
    columns_amount = headers.size
    if ImGui.begin_table(title, columns_amount)
      ImGui.table_next_row
      ImGui.table_next_column
      headers.each do |header|
        ImGui.text header
        ImGui.table_next_column
      end

      yield

      ImGui.end_table
    end
  end

  def draw_table_line(*columns : String | Proc)
    ImGui.table_next_row
    columns.each do |column|
      draw_table_cell(column)
    end
  end

  def draw_table_cell(cell : String | Proc)
    ImGui.table_next_column
    if cell.is_a?(String)
      ImGui.text cell
    else
      cell.call
    end
  end

  def draw_table_cell(&block)
    ImGui.table_next_column
    yield
  end

  # def draw_table_next_line
  #   ImGui.table_next_row
  # end

end
