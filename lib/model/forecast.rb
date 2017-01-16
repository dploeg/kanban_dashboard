class Forecast

  attr_accessor :percentile, :duration_weeks, :complete_date

  def initialize(args)
    args.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def ==(other)
    self.percentile == other.percentile && self.duration_weeks == other.duration_weeks && self.complete_date == other.complete_date
=begin
    return true if self===other
    return false if other.class != self.class

    if (self.percentile.nil? !@:)

    if (one != null ? !one.equals(test.one) : test.one != null) return false;
    if (two != null ? !two.equals(test.two) : test.two != null) return false;
    return three != null ? three.equals(test.three) : test.three == null;

=end
  end

  def to_s
    "Forecast(Percentile: #{@percentile}, duration_weeks: #{@duration_weeks}, complete_date: #{@complete_date}, object_id: #{"0x00%x" % (object_id << 1)})"
  end
end