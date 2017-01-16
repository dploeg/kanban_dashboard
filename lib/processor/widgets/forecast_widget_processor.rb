require 'dashing/app'
require_relative 'widget_processor'
require_relative '../../../lib/model/work_item'
require_relative '../../../lib/model/forecast'
require_relative '../../../lib/model/forecast_input'
require_relative '../../../lib/processor/widgets/data/started_vs_completed_data_processor'

class ForecastWidgetProcessor < WidgetProcessor
  include StartedVsCompletedDataProcessor

  attr_reader :forecasts

  MAX_SAMPLES = 1000

  def initialize
    super('forecast')
    @forecasts = Hash.new
  end

  def process(work_items)
    super(work_items)
    forecast_input = ForecastInput.new(:start_date => "10/3/16", :number_of_stories => 30)
    forecast(forecast_input, @completed)
  end

  def forecast(forecast_input, completed_items)
    samples = generate_samples(forecast_input, completed_items)

    populate_forecasts(forecast_input, samples)
  end

  def build_output_hash
    output = Hash.new

    output[:datasets] = build_datasets
    output[:options] = build_options

    output
  end


  private def populate_forecasts(forecast_input, samples)
    duration_weeks = samples.percentile(85).to_i
    complete_date = Date.strptime(forecast_input.start_date, WorkItem::DATE_FORMAT) + duration_weeks*7
    @forecasts[:percentile85] = Forecast.new(:percentile => 85, :duration_weeks => duration_weeks, :complete_date => complete_date.strftime(WorkItem::DATE_FORMAT))
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

  private def build_datasets
    datasets = Array.new
    forecasts = Hash.new
    forecasts[:label] = "Forecast"
    current_forecast = @forecasts[:percentile85]
    points = Array.new
    points.push({:x => Date.strptime(current_forecast.complete_date, WorkItem::DATE_FORMAT), :y => current_forecast.percentile, :r => 5})
    forecasts[:data] = points
    forecasts[:backgroundColor] = "#F7464A"
    forecasts[:hoverBackgroundColor] = "#FF6384"
    datasets.push(forecasts)
    datasets
  end

  private def build_options
    {

    }
  end
end