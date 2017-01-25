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
      @configuration = {:forecast_config=>{:start_date=>"10/3/16", :number_of_stories=>30}}
      @forecast_input = ForecastInput.new(@configuration[:forecast_config])
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
        widget.process(@work_items, @configuration)
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

      (0..100).step(5) do |value|
        percentile_symbol = ("percentile" + value.to_s).to_sym
        assert_equal Forecast.new(:percentile => value, :duration_weeks => 8, :complete_date => "05/05/16"), widget.forecasts[percentile_symbol]
      end
    end

    context "incomplete data" do

      should "filter items without a complete date" do
        @work_items = [[WorkItem.new(:start_date => "10/3/16", :complete_date => "11/3/16")] * 2,
                       [WorkItem.new(:start_date => "10/3/16", :complete_date => "18/3/16")] * 6,
                       [WorkItem.new(:start_date => "10/3/16", :complete_date => "25/3/16")] * 1,
                       [WorkItem.new(:start_date => "10/3/16", :complete_date => "1/4/16")] * 4,
                       [WorkItem.new(:start_date => "10/3/16", :complete_date => "8/4/16")] * 5,
                       [WorkItem.new(:start_date => "10/3/16", :complete_date => "22/4/16")] * 7,
                       [WorkItem.new(:start_date => "10/3/16")] * 4
        ].flatten
        @completed_items = {"2016-11" => 2, "2016-12" => 6, "2016-13" => 1, "2016-14" => 4, "2016-15" => 5, "2016-16" => 0, "2016-17" => 7}
        widget = ForecastWidgetProcessor.new

        sample = MiniTest::Mock.new
        #mocking doesn't allow to specify always just do this, so doing it a whole bunch of times
        (1..10000).each {
          sample.expect :call, 4, [@completed_items.values]
        }
        widget.stub :sample, sample do
          widget.process(@work_items, @configuration)
        end

        output_hash = widget.build_output_hash

        assert_equal 2, output_hash.size
        check_output(output_hash)

      end
    end


    should 'call send_event' do
      widget = ForecastWidgetProcessor.new
      widget.process(@work_items, @configuration)

      send_event = MiniTest::Mock.new
      send_event.expect :call, nil, ['forecast', widget.build_output_hash]
      widget.stub :send_event, send_event do
        widget.output
      end

      send_event.verify
    end
  end

  private def check_output(output_hash)
    check_heading_row(output_hash)
    check_data_rows(output_hash)
  end

  def check_data_rows(output_hash)
    assert_equal 21, output_hash[:rows].size
    counter =0
    check_reverse_order(output_hash) #    p 10.step(by: -1).take(4)
    100.step(0, -5) { |percentile_value|
      assert_equal 3, output_hash[:rows][counter][:cols].size
      assert_equal percentile_value.to_s + "%", output_hash[:rows][counter][:cols][0][:value]
      assert_equal 8, output_hash[:rows][counter][:cols][1][:value]
      assert_equal "05/05/16", output_hash[:rows][counter][:cols][2][:value]
      check_colors(output_hash[:rows][counter])
      counter+=1
    }
  end

  def check_colors(row)
    if row[:cols][0][:value].split("%")[0].to_i < 50
      assert_equal 'background-color:#f5e5d7;', row[:style]
    elsif row[:cols][0][:value].split("%")[0].to_i < 85
      assert_equal 'background-color:#fbf2cd;', row[:style]
    else
      assert_equal 'background-color:#cedeb5;', row[:style]
    end
  end

  def check_reverse_order(output_hash)
    assert_equal 100.to_s + "%", output_hash[:rows][0][:cols][0][:value]
    assert_equal 0.to_s + "%", output_hash[:rows][20][:cols][0][:value]
  end

  def check_heading_row(output_hash)
    assert_equal 1, output_hash[:hrows].size
    assert_equal 3, output_hash[:hrows][0][:cols].size
    assert_equal "Likelihood", output_hash[:hrows][0][:cols][0][:value]
    assert_equal "Duration (weeks)", output_hash[:hrows][0][:cols][1][:value]
    assert_equal "Completion Date", output_hash[:hrows][0][:cols][2][:value]
  end
end