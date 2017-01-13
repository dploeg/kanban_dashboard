require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/processor/widgets/lead_time_percentile_summary_widget_processor'
require_relative '../../../lib/model/work_item'
require_relative '../../test_constants'

class TestLeadTimeDistributionWidgetProcessor < Minitest::Test
  include TestConstants

  context 'LeadTimeDistributionWidgetProcessor' do

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

    should 'output hash' do
      output_hash = process_and_build_output_hash
      check_output(output_hash)
    end


    should "set options with multiple steps for y axis:  max <10 " do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "11/3/16")] * 81
      output_hash = process_and_build_output_hash

      assert_equal 1, output_hash[:options].size
      assert_equal 0, output_hash[:options][:scales][:yAxes][0][:ticks][:min]
      assert_equal 9, output_hash[:options][:scales][:yAxes][0][:ticks][:stepSize]
      assert_equal 90, output_hash[:options][:scales][:yAxes][0][:ticks][:max]
      assert_equal false, output_hash[:options][:scales][:yAxes][0][:stacked]

    end

    should "set options with multiple steps for y axis:  max < 100" do
      # @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => (Date.strptime("10/3/16", WorkItem::DATE_FORMAT) + 81).strftime(WorkItem::DATE_FORMAT))]
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")] * 81
      output_hash = process_and_build_output_hash

      assert_equal 1, output_hash[:options].size
      assert_equal 0, output_hash[:options][:scales][:yAxes][0][:ticks][:min]
      # assert_equal 0, output_hash[:options][:scales][:yAxes][0][:ticks][:min]
      assert_equal 9, output_hash[:options][:scales][:yAxes][0][:ticks][:stepSize]
      assert_equal 90, output_hash[:options][:scales][:yAxes][0][:ticks][:max]
      assert_equal false, output_hash[:options][:scales][:yAxes][0][:stacked]

    end

    should "set options with multiple steps for y axis: max > 100" do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")] * 112
      # @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => (Date.strptime("10/3/16", WorkItem::DATE_FORMAT) + 112).strftime(WorkItem::DATE_FORMAT))]
      output_hash = process_and_build_output_hash

      assert_equal 1, output_hash[:options].size
      assert_equal 0, output_hash[:options][:scales][:yAxes][0][:ticks][:min]
      assert_equal 12, output_hash[:options][:scales][:yAxes][0][:ticks][:stepSize]
      assert_equal 120, output_hash[:options][:scales][:yAxes][0][:ticks][:max]
      assert_equal false, output_hash[:options][:scales][:yAxes][0][:stacked]

    end

    should 'call send_event' do
      widget = LeadTimeDistributionWidgetProcessor.new
      widget.process @work_items

      send_event = MiniTest::Mock.new
      send_event.expect :call, nil, ['lead_time_distribution', widget.build_output_hash]
      widget.stub :send_event, send_event do
        widget.output
      end

      send_event.verify
    end


  end

  private def process_and_build_output_hash
    widget = LeadTimeDistributionWidgetProcessor.new
    widget.process @work_items

    widget.build_output_hash
  end

  private def check_output(output)
    assert_equal 3, output.keys.size

    check_output_labels(output)
    assert_equal 1, output[:options].size
    assert_equal 1, output[:options][:scales][:yAxes][0][:ticks][:stepSize]
    assert_equal false, output[:options][:scales][:yAxes][0][:stacked]
    check_datasets(output)

  end

  def check_datasets(output)
    assert_equal 1, output[:datasets].size
    planned = output[:datasets][0]
    assert_equal planned[:label], 'Planned'

    assert_same_elements [1, 2, 2, 2, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0], planned[:data]

    check_formatting(planned)
  end

  def check_formatting(planned)
    check_settings(planned[:backgroundColor], 'rgba(255, 206, 86, 0.2)')
    check_settings(planned[:borderColor], 'rgba(255, 206, 86, 1)')
    assert_equal 1, planned[:borderWidth]
  end

  def check_settings(setting_array, setting)
    assert_equal 20, setting_array.size
    setting_array.each { |background|
      assert_equal setting, background
    }
  end

  def check_output_labels(output)
    labels = output[:labels]
    assert_equal 20, labels.size
    counter = 0
    min = 6
    increments = 2
    labels.each { |label|
      assert_equal min + counter * increments, label
      counter=counter+1
    }
  end

end