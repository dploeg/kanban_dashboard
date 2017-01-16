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
end