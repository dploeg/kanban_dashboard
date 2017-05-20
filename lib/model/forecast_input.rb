class ForecastInput

  attr_accessor :start_date, :min_number_of_stories, :max_number_of_stories, :story_split_rate_low, :story_split_rate_high, :risks

  def initialize(args)
    args.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def to_s
    "Start Date: #{@start_date}, Minimum Number of stories: #{@min_number_of_stories}, Maximum Number of stories: #{@max_number_of_stories}, Story Split rate low: #{@story_split_rate_low}, Story Split rate high: #{@story_split_rate_high}, Risks: #{@risks}, object_id: #{"0x00%x" % (object_id << 1)})"
  end

end