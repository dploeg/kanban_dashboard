require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../lib/renderer/control_chart_widget_renderer'
require_relative '../../lib/model/work_item'
require_relative '../test_constants'

class TestControlChartWidgetRenderer < Minitest::Test
  include TestConstants

  context 'ControlChartWidgetProcessor' do

    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")]
    end

    should "create a base output hash for a single item" do
      output_hash = process_and_build_output_hash

      assert_equal 2, output_hash.size
      assert_equal 1, output_hash[:datasets][0][:data].size

      assert_equal 1, output_hash[:datasets][0][:data][0][:x]
      assert_equal 11, output_hash[:datasets][0][:data][0][:y]

    end

    should "decorate with additional layout data" do
      output_hash = process_and_build_output_hash

      assert_equal 2, output_hash.size
      assert_equal "Standard", output_hash[:datasets][0][:label]
      assert_equal "#F7464A", output_hash[:datasets][0][:backgroundColor]
      assert_equal "#FF6384", output_hash[:datasets][0][:hoverBackgroundColor]
    end

    should "add options" do
      output_hash = process_and_build_output_hash

      refute_nil output_hash[:options]
      expected_options = {
          scales: {
              xAxes: [{
                          ticks: {
                              beginAtZero: true,
                              :stepSize => 1,
                              :min => 0,
                              :max => 1
                          },
                          scaleLabel: {
                              display: true,
                              labelString: "Work Item"
                          }

                      }],
              yAxes: [{
                          ticks: {
                              beginAtZero: true,
                              :stepSize => 1,
                              :min => 0,
                              :max => 11
                          },
                          scaleLabel: {
                              display: true,
                              labelString: "Lead Time"
                          }
                      }]
          }
      }
      assert_equal expected_options, output_hash[:options]

    end

    context "y axis" do
      should "set options with multiple steps for with max <10 " do
        @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "11/3/16")] * 1
        output_hash = process_and_build_output_hash

        assert_equal 1, output_hash[:options].size
        assert_equal 0, output_hash[:options][:scales][:yAxes][0][:ticks][:min]
        assert_equal 1, output_hash[:options][:scales][:yAxes][0][:ticks][:stepSize]
        assert_equal 1, output_hash[:options][:scales][:yAxes][0][:ticks][:max]

      end

      should "set options with multiple steps for with max  >10 " do
        set_work_items_to_increment_lead_time_with_instances(11)
        output_hash = process_and_build_output_hash

        assert_equal 1, output_hash[:options].size
        assert_equal 0, output_hash[:options][:scales][:yAxes][0][:ticks][:min]
        assert_equal 1, output_hash[:options][:scales][:yAxes][0][:ticks][:stepSize]
        assert_equal 11, output_hash[:options][:scales][:yAxes][0][:ticks][:max]

      end

      should "set options with multiple steps for with max < 100" do
        set_work_items_to_increment_lead_time_with_instances(81)
        output_hash = process_and_build_output_hash

        assert_equal 1, output_hash[:options].size
        assert_equal 0, output_hash[:options][:scales][:yAxes][0][:ticks][:min]
        assert_equal 5, output_hash[:options][:scales][:yAxes][0][:ticks][:stepSize]
        assert_equal 100, output_hash[:options][:scales][:yAxes][0][:ticks][:max]

      end

      should "set options with multiple steps for with max > 200" do
        set_work_items_to_increment_lead_time_with_instances(225)
        output_hash = process_and_build_output_hash

        assert_equal 1, output_hash[:options].size
        assert_equal 0, output_hash[:options][:scales][:yAxes][0][:ticks][:min]
        assert_equal 12, output_hash[:options][:scales][:yAxes][0][:ticks][:stepSize]
        assert_equal 240, output_hash[:options][:scales][:yAxes][0][:ticks][:max]

      end
    end

    context "x axis" do
      should "set options with multiple steps for with max <10 " do
        @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "11/3/16")] * 1
        output_hash = process_and_build_output_hash

        assert_equal 1, output_hash[:options].size
        assert_equal 0, output_hash[:options][:scales][:xAxes][0][:ticks][:min]
        assert_equal 1, output_hash[:options][:scales][:xAxes][0][:ticks][:stepSize]
        assert_equal 1, output_hash[:options][:scales][:xAxes][0][:ticks][:max]

      end

      should "set options with multiple steps for with max  >10 " do
        @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "11/3/16")] * 11
        output_hash = process_and_build_output_hash

        assert_equal 1, output_hash[:options].size
        assert_equal 0, output_hash[:options][:scales][:xAxes][0][:ticks][:min]
        assert_equal 1, output_hash[:options][:scales][:xAxes][0][:ticks][:stepSize]
        assert_equal 11, output_hash[:options][:scales][:xAxes][0][:ticks][:max]

      end

      should "set options with multiple steps for with max < 100" do
        @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "11/3/16")] * 81
        output_hash = process_and_build_output_hash

        assert_equal 1, output_hash[:options].size
        assert_equal 0, output_hash[:options][:scales][:xAxes][0][:ticks][:min]
        assert_equal 5, output_hash[:options][:scales][:xAxes][0][:ticks][:stepSize]
        assert_equal 100, output_hash[:options][:scales][:xAxes][0][:ticks][:max]

      end

      should "set options with multiple steps for with max > 200" do
        @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "11/3/16")] * 225
        output_hash = process_and_build_output_hash

        assert_equal 1, output_hash[:options].size
        assert_equal 0, output_hash[:options][:scales][:xAxes][0][:ticks][:min]
        assert_equal 12, output_hash[:options][:scales][:xAxes][0][:ticks][:stepSize]
        assert_equal 240, output_hash[:options][:scales][:xAxes][0][:ticks][:max]

      end
    end

    should "order items based on complete date" do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"), #11
                     WorkItem.new(:start_date => "19/3/16", :complete_date => "19/4/16"), #31
                     WorkItem.new(:start_date => "15/3/16", :complete_date => "22/3/16"), #7
                     WorkItem.new(:start_date => "21/3/16", :complete_date => "17/4/16"), #27
                     WorkItem.new(:start_date => "25/3/16", :complete_date => "17/4/16"), #23
                     WorkItem.new(:start_date => "12/3/16", :complete_date => "14/4/16"), #33
                     WorkItem.new(:start_date => "28/3/16", :complete_date => "22/4/16")] #25

      output_hash = process_and_build_output_hash

      assert_equal 7, output_hash[:datasets][0][:data].size

      for i in 1..6
        assert_equal i, output_hash[:datasets][0][:data][i-1][:x]
        assert_equal 5, output_hash[:datasets][0][:data][i][:r]
      end

      assert_equal 11, output_hash[:datasets][0][:data][0][:y]
      assert_equal 7, output_hash[:datasets][0][:data][1][:y]
      assert_equal 33, output_hash[:datasets][0][:data][2][:y]
      assert_equal 27, output_hash[:datasets][0][:data][3][:y]
      assert_equal 23, output_hash[:datasets][0][:data][4][:y]
      assert_equal 31, output_hash[:datasets][0][:data][5][:y]
      assert_equal 25, output_hash[:datasets][0][:data][6][:y]

    end

    should "output" do
      widget = ControlChartWidgetRenderer.new
      widget.prepare @work_items

      send_event = MiniTest::Mock.new
      send_event.expect :call, nil, ['control_chart', widget.build_output_hash]
      widget.stub :send_event, send_event do
        widget.output
      end

      send_event.verify
    end

    should "add classes of service" do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"), #1
                     WorkItem.new(:start_date => "15/3/16", :complete_date => "21/3/16"), #2
                     WorkItem.new(:start_date => "12/3/16", :complete_date => "14/4/16"), #8
                     WorkItem.new(:start_date => "19/3/16", :complete_date => "19/4/16"), #10
                     WorkItem.new(:start_date => "21/3/16", :complete_date => "17/4/16"), #9
                     WorkItem.new(:start_date => "28/3/16", :complete_date => "22/4/16"), #11
                     WorkItem.new(:start_date => "2/4/16", :complete_date => "25/4/16", :class_of_service => TestConstants::STANDARD), #12
                     WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16"), #3

                     WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16", :class_of_service => TestConstants::EXPEDITE), #4
                     WorkItem.new(:start_date => "2/4/16", :complete_date => "13/4/16", :class_of_service => TestConstants::FIXED_DATE), #5
                     WorkItem.new(:start_date => "5/4/16", :complete_date => "25/4/16", :class_of_service => TestConstants::INTANGIBLE), #13
                     WorkItem.new(:start_date => "6/4/16", :complete_date => "13/4/16", :class_of_service => TestConstants::EXPEDITE), #6
                     WorkItem.new(:start_date => "7/4/16", :complete_date => "14/4/16", :class_of_service => TestConstants::EXPEDITE), #7
                     WorkItem.new(:start_date => "6/4/16", :complete_date => "28/4/16", :class_of_service => TestConstants::FIXED_DATE), #14
                     WorkItem.new(:start_date => "13/4/16", :complete_date => "12/5/16", :class_of_service => TestConstants::INTANGIBLE), #15
      ]

      widget = ControlChartWidgetRenderer.new
      widget.prepare @work_items

      output_hash = widget.build_output_hash
      assert_equal 8, output_hash[:datasets].size

      check_CoS_labels(output_hash)
      check_CoS_background_colors(output_hash)
      check_CoS_hover_background_colors(output_hash)

      check_x_positions(output_hash)

    end

    context "incomplete data" do

      should "filter items without a complete date" do
        @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"),
                       WorkItem.new(:start_date => "12/3/16")]
        output_hash = process_and_build_output_hash

        assert_equal 2, output_hash.size
        assert_equal 1, output_hash[:datasets][0][:data].size

        assert_equal 1, output_hash[:datasets][0][:data][0][:x]
        assert_equal 11, output_hash[:datasets][0][:data][0][:y]

      end
    end

    context "percentile line" do

      should "add a percentile line for single class of service" do
        @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"),
                       WorkItem.new(:start_date => "15/3/16", :complete_date => "21/3/16"),
                       WorkItem.new(:start_date => "12/3/16", :complete_date => "14/4/16"),
                       WorkItem.new(:start_date => "19/3/16", :complete_date => "19/4/16"),
                       WorkItem.new(:start_date => "21/3/16", :complete_date => "17/4/16"),
                       WorkItem.new(:start_date => "28/3/16", :complete_date => "22/4/16"),
                       WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16")
        ]

        widget = ControlChartWidgetRenderer.new
        widget.prepare @work_items
        output_hash = widget.build_output_hash
        assert_equal 2, output_hash[:datasets].size

        check_percentile_line_base_data(output_hash[:datasets][1], STANDARD, "#F7464A")
        check_percentile_data(output_hash, 32, 8, 1)
      end

      should "add multiple percentile lines - one per class of service" do
        @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"), #1
                       WorkItem.new(:start_date => "15/3/16", :complete_date => "21/3/16"), #2
                       WorkItem.new(:start_date => "12/3/16", :complete_date => "14/4/16"), #8
                       WorkItem.new(:start_date => "19/3/16", :complete_date => "19/4/16"), #10
                       WorkItem.new(:start_date => "21/3/16", :complete_date => "17/4/16"), #9
                       WorkItem.new(:start_date => "28/3/16", :complete_date => "22/4/16"), #11
                       WorkItem.new(:start_date => "2/4/16", :complete_date => "25/4/16", :class_of_service => TestConstants::STANDARD), #12
                       WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16"), #3

                       WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16", :class_of_service => TestConstants::EXPEDITE), #4
                       WorkItem.new(:start_date => "2/4/16", :complete_date => "13/4/16", :class_of_service => TestConstants::FIXED_DATE), #5
                       WorkItem.new(:start_date => "5/4/16", :complete_date => "25/4/16", :class_of_service => TestConstants::INTANGIBLE), #13
                       WorkItem.new(:start_date => "6/4/16", :complete_date => "13/4/16", :class_of_service => TestConstants::EXPEDITE), #6
                       WorkItem.new(:start_date => "7/4/16", :complete_date => "14/4/16", :class_of_service => TestConstants::EXPEDITE), #7
                       WorkItem.new(:start_date => "6/4/16", :complete_date => "28/4/16", :class_of_service => TestConstants::FIXED_DATE), #14
                       WorkItem.new(:start_date => "13/4/16", :complete_date => "12/5/16", :class_of_service => TestConstants::INTANGIBLE), #15
        ]

        widget = ControlChartWidgetRenderer.new
        widget.prepare @work_items

        output_hash = widget.build_output_hash
        assert_equal 8, output_hash[:datasets].size
        check_percentile_line_base_data(output_hash[:datasets][4], STANDARD, "#F7464A")
        check_percentile_line_base_data(output_hash[:datasets][5], EXPEDITE, "#F79B46")
        check_percentile_line_base_data(output_hash[:datasets][6], FIXED_DATE, "#464AF7")
        check_percentile_line_base_data(output_hash[:datasets][7], INTANGIBLE, "#F7F446")
        check_percentile_data(output_hash, 32, 16, 4)
        check_percentile_data(output_hash, 8, 16, 5)
        check_percentile_data(output_hash, 21, 16, 6)
        check_percentile_data(output_hash, 28, 16, 7)
      end
    end

  end


  private def set_work_items_to_increment_lead_time_with_instances(instances)
    items = Array.new
    (1..instances).each { |counter|
      items.push(WorkItem.new(:start_date => "10/3/16",
                              :complete_date => (Date.strptime("10/3/16", WorkItem::DATE_FORMAT) + counter).strftime(WorkItem::DATE_FORMAT)))
    }
    @work_items = items
  end

  private def check_x_positions(output_hash)
    assert_equal 8, output_hash[:datasets][0][:data][3][:x] #7
    assert_equal 6, output_hash[:datasets][1][:data][1][:x] #7
    assert_equal 14, output_hash[:datasets][2][:data][1][:x]
  end

  private def process_and_build_output_hash
    widget = ControlChartWidgetRenderer.new
    widget.prepare @work_items

    widget.build_output_hash
  end

  private def check_CoS_labels(output_hash)
    assert_equal STANDARD, output_hash[:datasets][0][:label]
    assert_equal EXPEDITE, output_hash[:datasets][1][:label]
    assert_equal FIXED_DATE, output_hash[:datasets][2][:label]
    assert_equal INTANGIBLE, output_hash[:datasets][3][:label]
  end

  private def check_CoS_background_colors(output_hash)
    assert_equal "#F7464A", output_hash[:datasets][0][:backgroundColor]
    assert_equal "#F79B46", output_hash[:datasets][1][:backgroundColor]
    assert_equal "#464AF7", output_hash[:datasets][2][:backgroundColor]
    assert_equal "#F7F446", output_hash[:datasets][3][:backgroundColor]
  end

  private def check_CoS_hover_background_colors(output_hash)
    assert_equal "#FF6384", output_hash[:datasets][0][:hoverBackgroundColor]
    assert_equal "#FF9063", output_hash[:datasets][1][:hoverBackgroundColor]
    assert_equal "#6384FF", output_hash[:datasets][2][:hoverBackgroundColor]
    assert_equal "#F9F777", output_hash[:datasets][3][:hoverBackgroundColor]
  end

  private def check_percentile_data(output_hash, percentile, number_of_items, class_of_service_index)
    assert_equal 1, output_hash[:datasets][class_of_service_index][:data][0][:x]
    assert_equal percentile, output_hash[:datasets][class_of_service_index][:data][0][:y]
    assert_equal number_of_items, output_hash[:datasets][class_of_service_index][:data][1][:x]
    assert_equal percentile, output_hash[:datasets][class_of_service_index][:data][1][:y]
  end

  private def check_percentile_line_base_data(percentile_data, class_of_service, color)
    assert_equal "line", percentile_data[:type]
    assert_equal class_of_service + " 95%", percentile_data[:label]
    assert_equal color, percentile_data[:borderColor]
    assert_equal 1, percentile_data[:borderWidth]
    assert_equal false, percentile_data[:fill]
    assert_equal 0, percentile_data[:pointRadius]
  end


end