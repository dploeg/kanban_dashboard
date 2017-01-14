require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/model/work_item'
require_relative '../../../lib/processor/widgets/started_vs_completed_widget_processor'
require_relative '../../../test/processor/widgets/started_vs_finished_test_helper'

class TestStartedVsCompletedWidgetProcessor < Minitest::Test
  include StartedVsFinishedTestHelper

  context 'StartedVsCompletedWidgetProcessor' do
    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")]
    end

    should "create a base output hash of data for a single item" do
      output_hash = process_and_build_output_hash
      assert_equal 2, output_hash[:datasets].size
      started = output_hash[:datasets][0]
      assert_equal started[:label], 'Started'
      completed = output_hash[:datasets][1]
      assert_equal completed[:label], 'Completed'

      assert_equal [1,0,0], started[:data]
      assert_equal [0,0,1], completed[:data]
    end

    should "create a base output hash of data for a single item with double digit month input" do
      @work_items = [WorkItem.new(:start_date => "07/01/16", :complete_date => "15/01/16")]
      output_hash = process_and_build_output_hash
      assert_equal 2, output_hash[:datasets].size
      started = output_hash[:datasets][0]
      assert_equal started[:label], 'Started'
      completed = output_hash[:datasets][1]
      assert_equal completed[:label], 'Completed'

      assert_equal [1,0], started[:data]
      assert_equal [0,1], completed[:data]
    end

    should "create a base output hash of data where item crosses year boundary" do
      @work_items = [WorkItem.new(:start_date => "23/12/16", :complete_date => "8/01/17")]
      output_hash = process_and_build_output_hash
      assert_equal 2, output_hash[:datasets].size
      started = output_hash[:datasets][0]
      assert_equal started[:label], 'Started'
      completed = output_hash[:datasets][1]
      assert_equal completed[:label], 'Completed'

      assert_equal [1,0,0,0], started[:data]
      assert_equal [0,0,0,1], completed[:data]
    end


    should "color started and completed for a single item" do
      output_hash = process_and_build_output_hash

      check_formatting_started(output_hash[:datasets][0])
      check_formatting_completed(output_hash[:datasets][1])
    end

    should "set labels for a single item" do
      output_hash = process_and_build_output_hash

      check_labels(output_hash)
    end

    context "y axis" do
      should "set options with single step for with max < 10" do
        output_hash = process_and_build_output_hash

        assert_equal 1, output_hash[:options].size
        assert_equal 0, output_hash[:options][:scales][:yAxes][0][:ticks][:min]
        assert_equal 1, output_hash[:options][:scales][:yAxes][0][:ticks][:stepSize]
        assert_equal 1, output_hash[:options][:scales][:yAxes][0][:ticks][:max]
        assert_equal false, output_hash[:options][:scales][:yAxes][0][:stacked]

      end

      should "set options with single step for y with max <15 " do
        @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")] * 11
        output_hash = process_and_build_output_hash

        assert_equal 1, output_hash[:options].size
        assert_equal 0, output_hash[:options][:scales][:yAxes][0][:ticks][:min]
        assert_equal 2, output_hash[:options][:scales][:yAxes][0][:ticks][:stepSize]
        assert_equal 20, output_hash[:options][:scales][:yAxes][0][:ticks][:max]
        assert_equal false, output_hash[:options][:scales][:yAxes][0][:stacked]

      end

      should "set options with multiple steps for with max < 100" do
        @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")] * 81
        output_hash = process_and_build_output_hash

        assert_equal 1, output_hash[:options].size
        assert_equal 0, output_hash[:options][:scales][:yAxes][0][:ticks][:min]
        assert_equal 9, output_hash[:options][:scales][:yAxes][0][:ticks][:stepSize]
        assert_equal 90, output_hash[:options][:scales][:yAxes][0][:ticks][:max]
        assert_equal false, output_hash[:options][:scales][:yAxes][0][:stacked]

      end

      should "set options with multiple steps for with max > 100" do
        @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")] * 112
        output_hash = process_and_build_output_hash

        assert_equal 1, output_hash[:options].size
        assert_equal 0, output_hash[:options][:scales][:yAxes][0][:ticks][:min]
        assert_equal 12, output_hash[:options][:scales][:yAxes][0][:ticks][:stepSize]
        assert_equal 120, output_hash[:options][:scales][:yAxes][0][:ticks][:max]
        assert_equal false, output_hash[:options][:scales][:yAxes][0][:stacked]

      end
    end

    should "create output" do
      widget = StartedVsCompletedWidgetProcessor.new
      widget.process @work_items

      send_event = MiniTest::Mock.new
      send_event.expect :call, nil, ['started_vs_finished', widget.build_output_hash]
      widget.stub :send_event, send_event do
        widget.output
      end

      send_event.verify
    end
  end

  private def process_and_build_output_hash
    widget = StartedVsCompletedWidgetProcessor.new
    widget.process @work_items

    widget.build_output_hash
  end
end