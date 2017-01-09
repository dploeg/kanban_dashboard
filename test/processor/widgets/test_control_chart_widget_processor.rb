require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/processor/widgets/control_chart_widget_processor'

class TestControlChartWidgetProcessor < Minitest::Test

  STANDARD = "Standard"
  EXPEDITE = "Expedite"
  FIXED_DATE = "Fixed Date"
  INTANGIBLE = "Intangible"


  context 'ControlChartWidgetProcessor' do

    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")]
    end

    should "create a base output hash for a single item" do
      output_hash = process_and_build_output_hash

      assert_equal 2, output_hash.size
      assert_equal 1, output_hash['datasets'][0][:data].size

      assert_equal 1, output_hash['datasets'][0][:data][0][:x]
      assert_equal 11, output_hash['datasets'][0][:data][0][:y]

    end

    should "decorate with additional layout data" do
      output_hash = process_and_build_output_hash

      assert_equal 2, output_hash.size
      assert_equal "Standard", output_hash['datasets'][0][:label]
      assert_equal "#F7464A", output_hash['datasets'][0][:backgroundColor]
      assert_equal "#FF6384", output_hash['datasets'][0][:hoverBackgroundColor]
    end

    should "add options" do
      output_hash = process_and_build_output_hash

      refute_nil output_hash['options']
      expected_options = {
                  scales: {
                      xAxes: [{
                          ticks: {
                              beginAtZero: true,
                              stepSize: 1.0
                          }
                      }],
                      yAxes: [{
                          ticks: {
                              beginAtZero: true,
                              fixedStepSize: 1.0
                          }
                      }]
                  }
      }
      assert_equal expected_options, output_hash['options']

    end

    should "order items based on complete date" do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"),   #11
                     WorkItem.new(:start_date => "19/3/16", :complete_date => "19/4/16"),   #31
                     WorkItem.new(:start_date => "15/3/16", :complete_date => "22/3/16"),   #7
                     WorkItem.new(:start_date => "21/3/16", :complete_date => "17/4/16"),   #27
                     WorkItem.new(:start_date => "25/3/16", :complete_date => "17/4/16"),   #23
                     WorkItem.new(:start_date => "12/3/16", :complete_date => "14/4/16"),   #33
                     WorkItem.new(:start_date => "28/3/16", :complete_date => "22/4/16")]   #25

      output_hash = process_and_build_output_hash

      assert_equal 7, output_hash['datasets'][0][:data].size

      for i in 1..6
        assert_equal i, output_hash['datasets'][0][:data][i-1][:x]
        assert_equal 5, output_hash['datasets'][0][:data][i][:r]
      end

      assert_equal 11, output_hash['datasets'][0][:data][0][:y]
      assert_equal 7, output_hash['datasets'][0][:data][1][:y]
      assert_equal 33, output_hash['datasets'][0][:data][2][:y]
      assert_equal 27, output_hash['datasets'][0][:data][3][:y]
      assert_equal 23, output_hash['datasets'][0][:data][4][:y]
      assert_equal 31, output_hash['datasets'][0][:data][5][:y]
      assert_equal 25, output_hash['datasets'][0][:data][6][:y]

    end

    should "output" do
      widget = ControlChartWidgetProcessor.new
      widget.process @work_items

      widget.output
    end

    should "add classes of service" do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"),
                     WorkItem.new(:start_date => "15/3/16", :complete_date => "21/3/16"),
                     WorkItem.new(:start_date => "12/3/16", :complete_date => "14/4/16"),
                     WorkItem.new(:start_date => "19/3/16", :complete_date => "19/4/16"),
                     WorkItem.new(:start_date => "21/3/16", :complete_date => "17/4/16"),
                     WorkItem.new(:start_date => "28/3/16", :complete_date => "22/4/16"),
                     WorkItem.new(:start_date => "2/4/16", :complete_date => "25/4/16", :class_of_service => STANDARD),
                     WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16"),

                     WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16", :class_of_service => EXPEDITE),
                     WorkItem.new(:start_date => "2/4/16", :complete_date => "13/4/16", :class_of_service => FIXED_DATE),
                     WorkItem.new(:start_date => "5/4/16", :complete_date => "25/4/16", :class_of_service => INTANGIBLE),
                     WorkItem.new(:start_date => "6/4/16", :complete_date => "13/4/16", :class_of_service => EXPEDITE),
                     WorkItem.new(:start_date => "7/4/16", :complete_date => "14/4/16", :class_of_service => EXPEDITE),
                     WorkItem.new(:start_date => "6/4/16", :complete_date => "28/4/16", :class_of_service => FIXED_DATE),
                     WorkItem.new(:start_date => "13/4/16", :complete_date => "12/5/16", :class_of_service => INTANGIBLE),
      ]

      widget = ControlChartWidgetProcessor.new
      widget.process @work_items

      output_hash = widget.build_output_hash
      puts output_hash.to_s
      assert_equal 4, output_hash['datasets'].size

      check_CoS_labels(output_hash)
      check_CoS_background_colors(output_hash)
      check_CoS_hover_background_colors(output_hash)

    end



  end


  def process_and_build_output_hash
    widget = ControlChartWidgetProcessor.new
    widget.process @work_items

    widget.build_output_hash
  end

  def check_CoS_labels(output_hash)
    assert_equal STANDARD, output_hash['datasets'][0][:label]
    assert_equal EXPEDITE, output_hash['datasets'][1][:label]
    assert_equal FIXED_DATE, output_hash['datasets'][2][:label]
    assert_equal INTANGIBLE, output_hash['datasets'][3][:label]
  end

  def check_CoS_background_colors(output_hash)
    assert_equal "#F7464A", output_hash['datasets'][0][:backgroundColor]
    assert_equal "#F79B46", output_hash['datasets'][1][:backgroundColor]
    assert_equal "#464AF7", output_hash['datasets'][2][:backgroundColor]
    assert_equal "#F7F446", output_hash['datasets'][3][:backgroundColor]
  end

  def check_CoS_hover_background_colors(output_hash)
    assert_equal "#FF6384", output_hash['datasets'][0][:hoverBackgroundColor]
    assert_equal "#FF9063", output_hash['datasets'][1][:hoverBackgroundColor]
    assert_equal "#6384FF", output_hash['datasets'][2][:hoverBackgroundColor]
    assert_equal "#F9F777", output_hash['datasets'][3][:hoverBackgroundColor]
  end

end