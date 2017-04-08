require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/model/work_item'
require_relative '../../../lib/model/forecast'
require_relative '../../../lib/model/forecast_input'
require_relative '../../../lib/processor/data/forecast_data_processor'

class TestForecastDataProcessor < Minitest::Test

  context 'process forecast data' do

    setup do
      @work_items = []
      @completed_items = {"2016-11" => 2, "2016-12" => 6, "2016-13" => 1, "2016-14" => 4, "2016-15" => 5, "2016-16" => 0, "2016-17" => 7, "2016-18" => 4}
      @configuration = {:forecast_config => {:start_date => "10/3/16", :min_number_of_stories => 30, :max_number_of_stories => 30}}
      @forecast_input = ForecastInput.new(@configuration[:forecast_config])
      @data = {:completed => @completed_items}
    end

    should 'calculate forecast' do
      processor = ForecastDataProcessor.new

      sample = MiniTest::Mock.new
      #mocking doesn't allow to specify always just do this, so doing it a whole bunch of times
      (1..10000).each {
        sample.expect :call, 4, [@completed_items.values]
      }
      processor.stub :sample, sample do
        data = processor.process(@work_items, @configuration, @data)
        forecasts = data[:forecasts]

        (0..100).step(5) do |value|
          forecast = forecasts[("percentile" + value.to_s).to_sym]
          assert_equal Forecast.new(:percentile => value, :duration_weeks => 8, :complete_date => "05/05/16"), forecast
        end
      end

    end

    should 'calculate forecast with story split rate' do
      @configuration = {:forecast_config => {:start_date => "10/3/16", :min_number_of_stories => 30, :max_number_of_stories => 30, :story_split_rate_low => 2.0, :story_split_rate_high => 3.5}}
      @forecast_input = ForecastInput.new(@configuration[:forecast_config])
      processor = ForecastDataProcessor.new

      sample = MiniTest::Mock.new
      random_split = MiniTest::Mock.new
      #mocking doesn't allow to specify always just do this, so doing it a whole bunch of times
      (1..100000).each {
        sample.expect :call, 4, [@completed_items.values]
      }
      (1..10000).each {
        random_split.expect :call, 2.5, [@forecast_input]
      }
      processor.stub :sample, sample do
        processor.stub :random_split, random_split do
          processor.forecast(@forecast_input, @completed_items)
          forecasts = processor.forecasts

          (0..100).step(5) do |value|
            forecast = forecasts[("percentile" + value.to_s).to_sym]
            assert_equal Forecast.new(:percentile => value, :duration_weeks => 19, :complete_date => "21/07/16"), forecast
          end
        end
      end
    end

    should 'calculate forecast with different min and max values' do
      processor = ForecastDataProcessor.new
      @configuration = {:forecast_config => {:start_date => "10/3/16", :min_number_of_stories => 10, :max_number_of_stories => 50}}
      @forecast_input = ForecastInput.new(@configuration[:forecast_config])

      sample = MiniTest::Mock.new
      random_story_value_from_range = MiniTest::Mock.new
      #mocking doesn't allow to specify always just do this, so doing it a whole bunch of times
      (1..10000).each {
        sample.expect :call, 4, [@completed_items.values]
      }
      (1..10000).each {
        random_story_value_from_range.expect :call, 30, [@configuration[:forecast_config][:min_number_of_stories], @configuration[:forecast_config][:max_number_of_stories]]
      }
      processor.stub :sample, sample do
        processor.stub :random_story_value_from_range, random_story_value_from_range do
          processor.forecast(@forecast_input, @completed_items)
          forecasts = processor.forecasts

          (0..100).step(5) do |value|
            forecast = forecasts[("percentile" + value.to_s).to_sym]
            assert_equal Forecast.new(:percentile => value, :duration_weeks => 8, :complete_date => "05/05/16"), forecast
          end
        end
      end
    end
  end

end