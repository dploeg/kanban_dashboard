class ForecastInput

  attr_accessor :start_date, :number_of_stories

  def initialize(args)
    args.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end
end