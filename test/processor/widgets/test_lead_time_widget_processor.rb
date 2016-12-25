require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/processor/widgets/LeadTimeWidgetProcessor'

class TestDataProcessor < Minitest::Test

  context 'LeadTimeWidgetProcessor' do

    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"),
                     WorkItem.new(:start_date => "15/3/16", :complete_date => "21/3/16"),
                     WorkItem.new(:start_date => "12/3/16", :complete_date => "14/4/16"),
                     WorkItem.new(:start_date => "19/3/16", :complete_date => "19/4/16"),
                     WorkItem.new(:start_date => "21/3/16", :complete_date => "17/4/16"),
                     WorkItem.new(:start_date => "28/3/16", :complete_date => "22/4/16"),
                     WorkItem.new(:start_date => "2/4/16", :complete_date => "25/4/16", :class_of_service => "Standard"),
                     WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16"),

                     WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16", :class_of_service => "Expedite"),
                     WorkItem.new(:start_date => "2/4/16", :complete_date => "13/4/16", :class_of_service => "Fixed Date"),
                     WorkItem.new(:start_date => "5/4/16", :complete_date => "25/4/16", :class_of_service => "Intangible"),
                     WorkItem.new(:start_date => "6/4/16", :complete_date => "13/4/16", :class_of_service => "Expedite"),
                     WorkItem.new(:start_date => "7/4/16", :complete_date => "14/4/16", :class_of_service => "Expedite"),
                     WorkItem.new(:start_date => "6/4/16", :complete_date => "28/4/16", :class_of_service => "Fixed Date"),
                     WorkItem.new(:start_date => "13/4/16", :complete_date => "12/5/16", :class_of_service => "Intangible"),
      ]

    end

    should 'process 95th percentile for widget' do
      widget = LeadTimeWidgetProcessor.new
      widget.process @work_items

      assert_equal 32, widget.lead_time_95th_percentile
    end

    should 'convert hashmap to send_event output' do
      widget = LeadTimeWidgetProcessor.new

      widget.process @work_items
      output = widget.convert_to_output

      check_output(output)

    end

    should 'output percentile' do
      widget = LeadTimeWidgetProcessor.new
      widget.process @work_items

      widget.output


    end

  end

  private def check_output(output)
    assert_equal 4, output.size
    assert_equal output[0]["label"], "Standard"
    assert_equal output[1]["label"], "Expedite"
    assert_equal output[2]["label"], "Fixed Date"
    assert_equal output[3]["label"], "Intangible"

    assert_equal output[0]["value"], 32
    assert_equal output[1]["value"], 8
    assert_equal output[2]["value"], 21
    assert_equal output[3]["value"], 28
  end

end
