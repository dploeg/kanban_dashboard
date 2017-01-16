require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/processor/widgets/forecast_widget_processor'

class TestForecastWidgetProcessor < Minitest::Test

  context 'ForecastWidgetProcessor' do

    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")]
      @completed_items = {"2016-11" => 2, "2016-12" => 6, "2016-13" => 1, "2016-14" => 4, "2016-15" => 5, "2016-16" => 0, "2016-17" => 7, "2016-18" => 4}
      @forecast_input = ForecastInput.new(:start_date => "10/3/16", :number_of_stories => 30)
    end

    should 'build output hash' do
      @work_items = [[WorkItem.new(:start_date => "10/3/16", :complete_date => "11/3/16")] * 2,
                     [WorkItem.new(:start_date => "10/3/16", :complete_date => "18/3/16")] * 6,
                     [WorkItem.new(:start_date => "10/3/16", :complete_date => "25/3/16")] * 1,
                     [WorkItem.new(:start_date => "10/3/16", :complete_date => "1/4/16")] * 4,
                     [WorkItem.new(:start_date => "10/3/16", :complete_date => "8/4/16")] * 5,
                     [WorkItem.new(:start_date => "10/3/16", :complete_date => "22/4/16")] * 7,
                     [WorkItem.new(:start_date => "10/3/16", :complete_date => "29/4/16")] * 4
      ].flatten
      widget = ForecastWidgetProcessor.new

      sample = MiniTest::Mock.new
      #mocking doesn't allow to specify always just do this, so doing it a whole bunch of times
      (1..10000).each {
        sample.expect :call, 4, [@completed_items.values]
      }
      widget.stub :sample, sample do
        widget.process(@work_items)
      end

      output_hash = widget.build_output_hash

      assert_equal 2, output_hash.size
      check_output(output_hash)
    end

    should 'calculate forecast' do
      widget = ForecastWidgetProcessor.new

      sample = MiniTest::Mock.new
      #mocking doesn't allow to specify always just do this, so doing it a whole bunch of times
      (1..10000).each {
        sample.expect :call, 4, [@completed_items.values]
      }
      widget.stub :sample, sample do
        widget.forecast(@forecast_input, @completed_items)
      end

      assert_equal Forecast.new(:percentile => 85, :duration_weeks => 8, :complete_date => "05/05/16"), widget.forecasts[:percentile85]
    end

    should 'call send_event' do
      widget = ForecastWidgetProcessor.new
      widget.process @work_items

      send_event = MiniTest::Mock.new
      send_event.expect :call, nil, ['forecast', widget.build_output_hash]
      widget.stub :send_event, send_event do
        widget.output
      end

      send_event.verify
    end
  end

  private def check_output(output_hash)
    assert_equal 1, output_hash[:datasets].size
    assert_equal "Forecast", output_hash[:datasets][0][:label]
    data = output_hash[:datasets][0][:data]
    assert_equal 1, data.size
    assert_equal Date.strptime("05/05/16", WorkItem::DATE_FORMAT),data[0][:x]
    assert_equal 85,data[0][:y]
    assert_equal 5,data[0][:r]

  end
end