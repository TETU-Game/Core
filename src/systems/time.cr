class TETU::TimeSystem
  include Entitas::Systems::ExecuteSystem
  include Entitas::Systems::InitializeSystem
  spoved_logger level: :info, io: STDOUT, bind: true

  @tick : Int64 = 0i64
  @last_tick : Time = Time.local
  @accumulated_duration : Time::Span = Time::Span.new
  @days : Int64 = 0i64
  @main_timeline : TimeEntity?

  def initialize(@contexts : Contexts)
  end

  def init
    init_main_timeline
    logger.info { "REAL_TIME_DAY_SPAN_MS=#{REAL_TIME_DAY_SPAN_MS}" }
    logger.info { "REAL_TIME_DAY_SPAN=#{REAL_TIME_DAY_SPAN}" }
  end

  # def main_timeline : TimeEntity
  #   @main_timeline || init_main_timeline
  # end

  def unsafe_main_timeline
    @main_timeline.as(TimeEntity)
  end

  def init_main_timeline
    @main_timeline = @contexts.time.create_entity
  end

  NANOMS_TO_MS          = 1_000_000
  REAL_TIME_DAY_SPAN_MS = GALAXY_CONF["real_time_day_span"].as_i
  REAL_TIME_DAY_SPAN    = Time::Span.new(nanoseconds: REAL_TIME_DAY_SPAN_MS * NANOMS_TO_MS)
  def execute
    unsafe_main_timeline.del_component_day_passed_event if unsafe_main_timeline.day_passed_event?

    new_tick = Time.local
    duration = new_tick - @last_tick
    @accumulated_duration += duration
    if @accumulated_duration >= REAL_TIME_DAY_SPAN
      @accumulated_duration -= REAL_TIME_DAY_SPAN
      unsafe_main_timeline.add_component_day_passed_event
      @days += 1i64
      logger.debug { "pass next day => #{@days}" }
    end

    @last_tick = new_tick
  end
end
