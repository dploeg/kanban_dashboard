require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/model/forecast'
require_relative '../../../lib/processor/widgets/forecast_vs_target_widget_renderer'

class TestForecastVsTargetWidgetRenderer < Minitest::Test

  context 'rendering' do

    setup do
      @work_items = []
      @forecasts = {"percentile0".to_sym => Forecast.new(:percentile => 0, :duration_weeks => 8, :complete_date => "01/01/16"),
                    "percentile5".to_sym => Forecast.new(:percentile => 5, :duration_weeks => 8, :complete_date => "08/01/16"),
                    "percentile10".to_sym => Forecast.new(:percentile => 10, :duration_weeks => 8, :complete_date => "15/01/16"),
                    "percentile15".to_sym => Forecast.new(:percentile => 15, :duration_weeks => 8, :complete_date => "22/01/16"),
                    "percentile20".to_sym => Forecast.new(:percentile => 20, :duration_weeks => 8, :complete_date => "01/02/16"),
                    "percentile25".to_sym => Forecast.new(:percentile => 25, :duration_weeks => 8, :complete_date => "08/02/16"),
                    "percentile30".to_sym => Forecast.new(:percentile => 30, :duration_weeks => 8, :complete_date => "15/02/16"),
                    "percentile35".to_sym => Forecast.new(:percentile => 35, :duration_weeks => 8, :complete_date => "22/02/16"),
                    "percentile40".to_sym => Forecast.new(:percentile => 40, :duration_weeks => 8, :complete_date => "01/03/16"),
                    "percentile45".to_sym => Forecast.new(:percentile => 45, :duration_weeks => 8, :complete_date => "08/03/16"),
                    "percentile50".to_sym => Forecast.new(:percentile => 50, :duration_weeks => 8, :complete_date => "15/03/16"),
                    "percentile55".to_sym => Forecast.new(:percentile => 55, :duration_weeks => 8, :complete_date => "22/03/16"),
                    "percentile60".to_sym => Forecast.new(:percentile => 60, :duration_weeks => 8, :complete_date => "29/03/16"),
                    "percentile65".to_sym => Forecast.new(:percentile => 65, :duration_weeks => 8, :complete_date => "01/04/16"),
                    "percentile70".to_sym => Forecast.new(:percentile => 70, :duration_weeks => 8, :complete_date => "08/04/16"),
                    "percentile75".to_sym => Forecast.new(:percentile => 75, :duration_weeks => 8, :complete_date => "15/04/16"),
                    "percentile80".to_sym => Forecast.new(:percentile => 80, :duration_weeks => 8, :complete_date => "22/04/16"),
                    "percentile85".to_sym => Forecast.new(:percentile => 85, :duration_weeks => 8, :complete_date => "29/04/16"),
                    "percentile90".to_sym => Forecast.new(:percentile => 90, :duration_weeks => 8, :complete_date => "01/05/16"),
                    "percentile95".to_sym => Forecast.new(:percentile => 95, :duration_weeks => 8, :complete_date => "08/05/16"),
                    "percentile100".to_sym => Forecast.new(:percentile => 100, :duration_weeks => 8, :complete_date => "15/05/16")}
      @data = {:forecasts => @forecasts}
      @configuration = {:forecast_config => {:start_date => "10/3/16", :min_number_of_stories => 30, :max_number_of_stories => 30, :target_complete_date => "21/4/16"}}
    end

    should 'display 8 percentile values and the target' do
      output_hash = process_and_build_output_hash

      assert_equal 2, output_hash.size
      check_number_of_data_elements(output_hash)
      check_element_labels(output_hash)
      check_target_percentile(output_hash)
    end

    context "options" do
      should "add options with daily time unit" do
        @forecasts = {"percentile0".to_sym => Forecast.new(:percentile => 0, :duration_weeks => 8, :complete_date => "01/04/16"),
                      "percentile5".to_sym => Forecast.new(:percentile => 5, :duration_weeks => 8, :complete_date => "02/04/16"),
                      "percentile10".to_sym => Forecast.new(:percentile => 10, :duration_weeks => 8, :complete_date => "03/04/16"),
                      "percentile15".to_sym => Forecast.new(:percentile => 15, :duration_weeks => 8, :complete_date => "05/04/16"),
                      "percentile20".to_sym => Forecast.new(:percentile => 20, :duration_weeks => 8, :complete_date => "07/04/16"),
                      "percentile25".to_sym => Forecast.new(:percentile => 25, :duration_weeks => 8, :complete_date => "09/04/16"),
                      "percentile30".to_sym => Forecast.new(:percentile => 30, :duration_weeks => 8, :complete_date => "11/04/16"),
                      "percentile35".to_sym => Forecast.new(:percentile => 35, :duration_weeks => 8, :complete_date => "12/04/16"),
                      "percentile40".to_sym => Forecast.new(:percentile => 40, :duration_weeks => 8, :complete_date => "13/04/16"),
                      "percentile45".to_sym => Forecast.new(:percentile => 45, :duration_weeks => 8, :complete_date => "14/04/16"),
                      "percentile50".to_sym => Forecast.new(:percentile => 50, :duration_weeks => 8, :complete_date => "15/04/16"),
                      "percentile55".to_sym => Forecast.new(:percentile => 55, :duration_weeks => 8, :complete_date => "16/04/16"),
                      "percentile60".to_sym => Forecast.new(:percentile => 60, :duration_weeks => 8, :complete_date => "18/04/16"),
                      "percentile65".to_sym => Forecast.new(:percentile => 65, :duration_weeks => 8, :complete_date => "20/04/16"),
                      "percentile70".to_sym => Forecast.new(:percentile => 70, :duration_weeks => 8, :complete_date => "22/04/16"),
                      "percentile75".to_sym => Forecast.new(:percentile => 75, :duration_weeks => 8, :complete_date => "24/04/16"),
                      "percentile80".to_sym => Forecast.new(:percentile => 80, :duration_weeks => 8, :complete_date => "26/04/16"),
                      "percentile85".to_sym => Forecast.new(:percentile => 85, :duration_weeks => 8, :complete_date => "28/04/16"),
                      "percentile90".to_sym => Forecast.new(:percentile => 90, :duration_weeks => 8, :complete_date => "01/05/16"),
                      "percentile95".to_sym => Forecast.new(:percentile => 95, :duration_weeks => 8, :complete_date => "03/05/16"),
                      "percentile100".to_sym => Forecast.new(:percentile => 100, :duration_weeks => 8, :complete_date => "05/05/16")}
        @data = {:forecasts => @forecasts}
        output_hash = process_and_build_output_hash

        refute_nil output_hash[:options]
        expected_options = {
            scales: {
                xAxes: [{
                            type: 'time',
                            time: {
                                unit: 'day'
                            },
                            scaleLabel: {
                                display: true,
                                labelString: "Date"
                            }

                        }],
                yAxes: [{
                            ticks: {
                                beginAtZero: true,
                                :stepSize => 5,
                                :min => 0,
                                :max => 100
                            },
                            scaleLabel: {
                                display: true,
                                labelString: "Percentile Complete"
                            }
                        }]
            }
        }
        assert_equal expected_options, output_hash[:options]
      end
      should "add options with weekly time unit" do
        output_hash = process_and_build_output_hash

        refute_nil output_hash[:options]
        expected_options = {
            scales: {
                xAxes: [{
                            type: 'time',
                            time: {
                                unit: 'week'
                            },
                            scaleLabel: {
                                display: true,
                                labelString: "Date"
                            }

                        }],
                yAxes: [{
                            ticks: {
                                beginAtZero: true,
                                :stepSize => 5,
                                :min => 0,
                                :max => 100
                            },
                            scaleLabel: {
                                display: true,
                                labelString: "Percentile Complete"
                            }
                        }]
            }
        }
        assert_equal expected_options, output_hash[:options]
      end
    end

  end

  private def process_and_build_output_hash
    widget = ForecastVsTargetWidgetRenderer.new
    widget.process @work_items, @configuration, @data

    widget.build_output_hash
  end

  private def check_number_of_data_elements(output_hash)
    assert_equal 4, output_hash[:datasets].size
    assert_equal 2, output_hash[:datasets][0][:data].size
    assert_equal 3, output_hash[:datasets][1][:data].size
    assert_equal 3, output_hash[:datasets][2][:data].size
    assert_equal 1, output_hash[:datasets][3][:data].size
  end

  private def check_element_labels(output_hash)
    assert_equal "Are you nuts?", output_hash[:datasets][0][:label]
    assert_equal "Caution", output_hash[:datasets][1][:label]
    assert_equal "Safe zone", output_hash[:datasets][2][:label]
    assert_equal "Target", output_hash[:datasets][3][:label]
  end

  private def check_target_percentile(output_hash)
    assert_equal 80, output_hash[:datasets][3][:data][0][:y]
  end

end