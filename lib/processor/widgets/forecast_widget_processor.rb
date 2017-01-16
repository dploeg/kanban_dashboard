require 'dashing/app'
require_relative 'widget_processor'
require_relative '../../../lib/model/work_item'
require_relative '../../../lib/model/forecast'
require_relative '../../../lib/model/forecast_input'

class ForecastWidgetProcessor < WidgetProcessor

  attr_reader :forecasts

  MAX_SAMPLES = 1000

  def initialize
    super('forecast')
    @forecasts = Hash.new
  end

  def forecast(forecast_input, completed_items)
    samples = generate_samples(forecast_input, completed_items)

    populate_forecasts(forecast_input, samples)
  end

  private def populate_forecasts(forecast_input, samples)
    duration_weeks = samples.percentile(85).to_i
    complete_date = Date.strptime(forecast_input.start_date, WorkItem::DATE_FORMAT) + duration_weeks*7
    @forecasts[:percentile85] = Forecast.new(:likelihood => 85, :duration_weeks => duration_weeks,  :complete_date => complete_date.strftime(WorkItem::DATE_FORMAT))
  end

  private def generate_samples(forecast_input, completed_items)
    samples = Array.new
    completed_values = completed_items.values

    (1..MAX_SAMPLES).each {
      stories_left = forecast_input.number_of_stories
      weeks_taken = 0
      while stories_left >= 0
        stories_left = stories_left - sample(completed_values)
        weeks_taken+=1
      end
      samples.push(weeks_taken)
    }
    samples
  end

  #pulled this out into a separate method to create seam in order to mock random values
  private def sample(completed_values)
    completed_values.sample
  end
end