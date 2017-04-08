require_relative '../../../lib/model/work_item'
require_relative '../../../lib/model/forecast'
require_relative '../../../lib/model/forecast_input'
require 'descriptive_statistics'

class ForecastDataProcessor

  MAX_SAMPLES = 1000
  attr_reader :forecasts

  def initialize
    @forecasts = Hash.new
  end

  def process(work_items, configuration = Hash.new, data = Hash.new)
    forecast_input = ForecastInput.new(configuration[:forecast_config])
    forecast(forecast_input, data[:completed])
    {:forecasts => @forecasts}
  end

  def forecast(forecast_input, completed_items)
    samples = generate_samples(forecast_input, completed_items)
    populate_forecasts(forecast_input, samples)
  end

  private def populate_forecasts(forecast_input, samples)
    (0..100).step(5) do |percentile_value|
      duration_weeks = samples.percentile(percentile_value).to_i
      complete_date = Date.strptime(forecast_input.start_date, WorkItem::DATE_FORMAT) + duration_weeks*7
      forecast_value = Forecast.new(:percentile => percentile_value, :duration_weeks => duration_weeks, :complete_date => complete_date.strftime(WorkItem::DATE_FORMAT))
      @forecasts[("percentile" + percentile_value.to_s).to_sym] = forecast_value
    end
  end

  private def generate_samples(forecast_input, completed_items)
    samples = Array.new
    completed_values = completed_items.values

    (1..MAX_SAMPLES).each {
      stories_left = calculate_stories_to_sample(forecast_input)
      weeks_taken = 0
      while stories_left >= 0
        stories_left = stories_left - sample(completed_values)
        weeks_taken+=1
      end
      samples.push(weeks_taken)
    }
    samples
  end

  def calculate_stories_to_sample(forecast_input)
    unless forecast_input.story_split_rate_low.nil? || forecast_input.story_split_rate_high.nil?
      random_story_value_from_range(forecast_input.min_number_of_stories, forecast_input.max_number_of_stories) * random_split(forecast_input)
    else
      random_story_value_from_range(forecast_input.min_number_of_stories, forecast_input.max_number_of_stories)
    end
  end

  #pulled this out into a separate method to create seam in order to mock random values
  private def sample(completed_values)
    completed_values.sample
  end

  #pulled this out into a separate method to create seam in order to mock random values
  private def random_split(forecast_input)
    if forecast_input.story_split_rate_high > forecast_input.story_split_rate_low
      rand(forecast_input.story_split_rate_low...forecast_input.story_split_rate_high)
    else
      forecast_input.story_split_rate_low
    end
  end

  #pulled this out into a separate method to create seam in order to mock random values
  private def random_story_value_from_range(min, max)
    if min == max || max.nil?
      min
    else
      rand(min..max)
    end
  end
end