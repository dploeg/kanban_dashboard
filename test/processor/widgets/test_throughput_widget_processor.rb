require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/processor/widgets/lead_time_percentile_summary_widget_processor'
require_relative '../../../lib/model/work_item'
require_relative '../../../test/processor/widgets/started_vs_completed_test_helper'
require_relative '../../test_constants'

class TestThroughputWidgetProcessor < Minitest::Test
  include TestConstants

  context 'ThroughputWidgetProcessor' do

    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"),
                     WorkItem.new(:start_date => "15/3/16", :complete_date => "21/3/16"),
                     WorkItem.new(:start_date => "12/3/16", :complete_date => "14/4/16"),
                     WorkItem.new(:start_date => "19/3/16", :complete_date => "19/4/16"),
                     WorkItem.new(:start_date => "21/3/16", :complete_date => "17/4/16"),
                     WorkItem.new(:start_date => "28/3/16", :complete_date => "22/4/16"),
                     WorkItem.new(:start_date => "2/4/16", :complete_date => "25/4/16", :class_of_service => TestConstants::STANDARD),
                     WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16"),

                     WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16", :class_of_service => TestConstants::EXPEDITE),
                     WorkItem.new(:start_date => "2/4/16", :complete_date => "13/4/16", :class_of_service => TestConstants::FIXED_DATE),
                     WorkItem.new(:start_date => "5/4/16", :complete_date => "25/4/16", :class_of_service => TestConstants::INTANGIBLE),
                     WorkItem.new(:start_date => "6/4/16", :complete_date => "13/4/16", :class_of_service => TestConstants::EXPEDITE),
                     WorkItem.new(:start_date => "7/4/16", :complete_date => "14/4/16", :class_of_service => TestConstants::EXPEDITE),
                     WorkItem.new(:start_date => "6/4/16", :complete_date => "28/4/16", :class_of_service => TestConstants::FIXED_DATE),
                     WorkItem.new(:start_date => "13/4/16", :complete_date => "12/5/16", :class_of_service => TestConstants::INTANGIBLE),
      ]
    end

    should 'output hash for single item' do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")]
      output_hash = process_and_build_output_hash
      check_output(output_hash)
    end

    should 'call send_event' do
      widget = ThroughputWidgetProcessor.new
      widget.process @work_items

      send_event = MiniTest::Mock.new
      send_event.expect :call, nil, ['throughput', widget.build_output_hash]
      widget.stub :send_event, send_event do
        widget.output
      end

      send_event.verify
    end
  end

  private def process_and_build_output_hash
    widget = ThroughputWidgetProcessor.new
    widget.process @work_items

    widget.build_output_hash
  end

  private def check_output(output)
    assert_equal 3, output.keys.size

    check_output_labels(output)
    check_options(output)
    check_datasets(output)

  end

  def check_options(output)
    assert_equal 1, output[:options].size
    assert_equal 1, output[:options][:scales][:yAxes][0][:ticks][:stepSize]
    assert_equal false, output[:options][:scales][:yAxes][0][:stacked]
    assert_equal true, output[:options][:scales][:yAxes][0][:scaleLabel][:display]
    assert_equal "Count of weeks with value", output[:options][:scales][:yAxes][0][:scaleLabel][:labelString]

    assert_equal true, output[:options][:scales][:xAxes][0][:scaleLabel][:display]
    assert_equal "Throughput value (number of items completed in a calendar week)", output[:options][:scales][:xAxes][0][:scaleLabel][:labelString]
  end

  def check_datasets(output)
    assert_equal 1, output[:datasets].size
    tp_frequency = output[:datasets][0]
    assert_equal tp_frequency[:label], 'Throughput Frequency'

    assert_same_elements [2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], tp_frequency[:data]
    check_formatting(tp_frequency)
  end

  def check_formatting(tp_frequency)
    check_settings(tp_frequency[:backgroundColor], 'rgba(255, 206, 86, 0.2)', tp_frequency[:data].size)
    check_settings(tp_frequency[:borderColor], 'rgba(255, 206, 86, 1)', tp_frequency[:data].size)
    assert_equal 1, tp_frequency[:borderWidth]
  end

  private def check_settings(setting_array, setting, number_of_values)
    assert_equal number_of_values, setting_array.size
    setting_array.each { |background|
      assert_equal setting, background
    }
  end

  def check_output_labels(output)
    labels = output[:labels]
    assert_equal 20, labels.size
    counter = 0
    min = 0
    increments = 1
    labels.each { |label|
      assert_equal min + counter * increments, label
      counter=counter+1
    }
  end
end
