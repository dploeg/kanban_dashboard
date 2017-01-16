class Forecast

  attr_accessor :percentile, :duration_weeks, :complete_date

  def initialize(args)
    args.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def ==(other)
    self.percentile == other.percentile && self.duration_weeks == other.duration_weeks && self.complete_date == other.complete_date
  end

  def to_s
    "Forecast(Percentile: #{@percentile}, duration_weeks: #{@duration_weeks}, complete_date: #{@complete_date}, object_id: #{"0x00%x" % (object_id << 1)})"
  end
end