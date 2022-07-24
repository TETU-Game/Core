class TETU::UiInitSystem
  include Entitas::Systems::ExecuteSystem
  include Entitas::Systems::InitializeSystem
  include Helpers::UiSystem
  spoved_logger level: :info, io: STDOUT, bind: true

  def initialize(@context : GameContext); end

  def init
    ImGui::SFML.init(window)
    window.framerate_limit = TETU::UI_CONF["framerate"].as_i64
  end

  def execute
    if !window.open?
      exit(0)
    end

    handle_events
    ImGui::SFML.update(window, delta_clock.restart)
    window.clear(SF::Color::Black)
  end

  private def handle_events
    while event = window.poll_event
      ImGui::SFML.process_event(window, event)

      case event
      when SF::Event::Closed
        window.close
      when SF::Event::KeyPressed
        logger.debug { "KeyPressed #{event}" }
      when SF::Event::MouseButtonEvent
        logger.debug { "MouseButtonEvent #{event}" }
      end
    end
  end
end
