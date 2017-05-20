require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../lib/renderer/forecast_widget_renderer'
require_relative '../../lib/model/forecast'

class TestForecastWidgetRenderer < Minitest::Test

  context 'ForecastWidgetProcessor' do

    setup do
      @work_items = []
      @forecasts = {:percentile0 => Forecast.new(:percentile => 0, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile5 => Forecast.new(:percentile => 5, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile10 => Forecast.new(:percentile => 10, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile15 => Forecast.new(:percentile => 15, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile20 => Forecast.new(:percentile => 20, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile25 => Forecast.new(:percentile => 25, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile30 => Forecast.new(:percentile => 30, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile35 => Forecast.new(:percentile => 35, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile40 => Forecast.new(:percentile => 40, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile45 => Forecast.new(:percentile => 45, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile50 => Forecast.new(:percentile => 50, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile55 => Forecast.new(:percentile => 55, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile60 => Forecast.new(:percentile => 60, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile65 => Forecast.new(:percentile => 65, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile70 => Forecast.new(:percentile => 70, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile75 => Forecast.new(:percentile => 75, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile80 => Forecast.new(:percentile => 80, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile85 => Forecast.new(:percentile => 85, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile90 => Forecast.new(:percentile => 90, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile95 => Forecast.new(:percentile => 95, :duration_weeks => 8, :complete_date => "05/05/16"),
                    :percentile100 => Forecast.new(:percentile => 100, :duration_weeks => 8, :complete_date => "05/05/16")}
      @data = {:forecasts => @forecasts}
      @configuration = {}
    end

    should 'build output hash' do
      widget = ForecastWidgetRenderer.new

      widget.prepare(@work_items, @configuration, @data)
      output_hash = widget.build_output_hash

      assert_equal 2, output_hash.size
      check_output(output_hash)
    end

    should 'call send_event' do
      @completed_items = {"2016-10" => 0, "2016-11" => 0, "2016-12" => 1}

      widget = ForecastWidgetRenderer.new
      widget.prepare(@work_items, @configuration, @data)

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