require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/processor/widgets/lead_time_distribution_widget_processor'
require_relative '../../test_constants'

class TestLeadTimePercentileSummaryWidgetProcessor < Minitest::Test
  include TestConstants

  context 'LeadTimePercentileSummaryWidgetProcessor' do

    setup do
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

    end

    should 'process 95th percentile for widget' do
      widget = LeadTimePercentileSummaryWidgetProcessor.new
      widget.process @work_items

      assert_equal 32, widget.lead_time_95th_percentile
      assert_equal 32, widget.lead_time_95th_percentile(STANDARD)
      assert_equal 8, widget.lead_time_95th_percentile(EXPEDITE)
      assert_equal 21, widget.lead_time_95th_percentile(FIXED_DATE)
      assert_equal 28, widget.lead_time_95th_percentile(INTANGIBLE)
    end

    should 'builds output map' do
      widget = LeadTimePercentileSummaryWidgetProcessor.new

      widget.process @work_items
      output = widget.build_output_hash

      check_output(output)

    end

    should 'output percentile' do
      widget = LeadTimePercentileSummaryWidgetProcessor.new
      widget.process @work_items

      send_event = MiniTest::Mock.new
      send_event.expect :call, nil, ['lead_times', widget.build_output_hash]
      widget.stub :send_event, send_event do
        widget.output
      end

      send_event.verify


    end

  end

  private def check_output(output_map)
    output = output_map["items"]
    assert_equal 4, output.size
    assert_equal output[0]["label"], TestConstants::STANDARD
    assert_equal output[1]["label"], TestConstants::EXPEDITE
    assert_equal output[2]["label"], TestConstants::FIXED_DATE
    assert_equal output[3]["label"], TestConstants::INTANGIBLE

    assert_equal output[0]["value"], 32
    assert_equal output[1]["value"], 8
    assert_equal output[2]["value"], 21
    assert_equal output[3]["value"], 28
  end

end
