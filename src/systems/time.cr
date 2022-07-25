class TETU::TimeSystem
  include Entitas::Systems::ExecuteSystem
  spoved_logger level: :info, io: STDOUT, bind: true

  @tick : Int64
  @last_tick : Time
  @accumulated_duration : Time::Span
  @main_timeline : TimeEntity

  def initialize(@contexts : Contexts)
    @tick = 0i64
    @last_tick = Time.local
    @accumulated_duration = Time::Span.new
    @main_timeline = @contexts.time.create_entity
  end

  NANO_SECOND           = 1_000_000
  REAL_TIME_DAY_SPAN_MS = GALAXY_CONF["real_time_day_span"].as_i
  REAL_TIME_DAY_SPAN    = Time::Span.new(nanoseconds: NANO_SECOND)
  def execute
    @main_timeline.del_component_day_passed_event if @main_timeline.day_passed_event?

    new_tick = Time.local
    duration = new_tick - @last_tick
    @accumulated_duration += duration
    if @accumulated_duration >= REAL_TIME_DAY_SPAN
      @accumulated_duration -= REAL_TIME_DAY_SPAN
      @main_timeline.add_component_day_passed_event
    end
  end
end
