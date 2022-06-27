module TETU::Helpers::UiSystem
  def window
    TETU::Window.instance.window
  end

  def delta_clock
    TETU::Window.instance.delta_clock
  end
end
