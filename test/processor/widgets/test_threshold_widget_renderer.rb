require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/model/work_item'
require_relative '../../../lib/model/threshold_warning'
require_relative '../../../lib/processor/widgets/threshold_widget_renderer'
require_relative '../../test_constants'

class TestThresholdWidgetRenderer < Minitest::Test
  include TestConstants


  context 'TestThresholdWidgetProcessor' do

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
                     WorkItem.new(:start_date => "13/4/16", :complete_date => "12/5/16", :class_of_service => TestConstants::INTANGIBLE)]
      @warning1 = ThresholdWarning.new("Started vs Completed", "has exceeded threshold of 5")
      @warning2 = ThresholdWarning.new("95 Percentile - Standard", "has exceeded threshold of 15")
      @warning3 = ThresholdWarning.new("95 Percentile - Expedite", "has exceeded threshold of 5")
      @warnings = [@warning1, @warning2, @warning3]
    end

    should 'defer to threshold processor' do
      @threshold_processor = MiniTest::Mock.new
      @threshold_processor.expect :process, @warnings, [@work_items]

      widget = ThresholdWidgetRenderer.new(@threshold_processor)

      widget.prepare(@work_items)

      @threshold_processor.verify
    end


    should 'build output hash with no warnings' do
      @threshold_processor = MiniTest::Mock.new
      @threshold_processor.expect :process, [], [@work_items]

      widget = ThresholdWidgetRenderer.new(@threshold_processor)

      widget.prepare(@work_items)

      @threshold_processor.verify

      output_hash = widget.build_output_hash
      check_output_hash_for_no_warnings(output_hash)
    end

    should 'build output hash with some warnings' do
      @threshold_processor = MiniTest::Mock.new
      @threshold_processor.expect :process, @warnings, [@work_items]

      widget = ThresholdWidgetRenderer.new(@threshold_processor)

      widget.prepare(@work_items)

      @threshold_processor.verify

      output_hash = widget.build_output_hash
      check_output_hash_for_warnings(output_hash)
    end

    should "call send_event to output results" do
      @threshold_processor = MiniTest::Mock.new
      @threshold_processor.expect :process, @warnings, [@work_items]

      widget = ThresholdWidgetRenderer.new(@threshold_processor)
      widget.prepare(@work_items)

      send_event = MiniTest::Mock.new
      send_event.expect :call, nil, ['thresholds', widget.build_output_hash]
      widget.stub :send_event, send_event do
        widget.output
      end

      send_event.verify
    end

  end

  private def check_output_hash_for_warnings(output_hash)
    output = output_hash['items']
    assert_equal 3, output.size
    assert_equal output[0]["label"], @warning1.label
    assert_equal output[1]["label"], @warning2.label
    assert_equal output[2]["label"], @warning3.label

    assert_equal output[0]["value"], @warning1.value
    assert_equal output[1]["value"], @warning2.value
    assert_equal output[2]["value"], @warning3.value
    assert_equal "warning", output_hash['status']
  end

  private def check_output_hash_for_no_warnings(output_hash)
    output = output_hash['items']
    assert_equal 0, output.size
    assert_equal "clear", output_hash['status']
  end

end
