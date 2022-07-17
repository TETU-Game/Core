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
    draw_table_line
    columns.each do |column|
      draw_table_cell(column)
    end
  end

  def draw_table_line
    ImGui.table_next_row
    # print "\n"
  end

  def draw_table_cell(cell : String | Proc)
    draw_table_cell
    if cell.is_a?(String)
      # print cell
      ImGui.text cell
    else
      # print cell.call
      cell.call
    end
  end

  def draw_table_cell(&block)
    draw_table_cell
    # print "YIELD"
    yield
  end

  def draw_table_cell
    ImGui.table_next_column
    # print "|"
  end

  # def draw_table_next_line
  #   ImGui.table_next_row
  # end

end
