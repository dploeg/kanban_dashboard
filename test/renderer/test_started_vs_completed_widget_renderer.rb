require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../lib/model/work_item'
require_relative '../../lib/renderer/started_vs_completed_widget_renderer'
require_relative 'started_vs_completed_test_helper'

class TestStartedVsCompletedWidgetRenderer < Minitest::Test
  include StartedVsCompletedTestHelper

  context 'StartedVsCompletedWidgetProcessor' do
    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")]
      @data = {:started => {"2016-10"=>1, "2016-11"=>0, "2016-12"=>0}, :completed => {"2016-10"=>0, "2016-11"=>0, "2016-12"=>1}}
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

    context "incomplete data" do

      should "filter items without a complete date" do
        @work_items.push(WorkItem.new(:start_date => "10/3/16"))
        @data = {:started => {"2016-10"=>2, "2016-11"=>0, "2016-12"=>0}, :completed => {"2016-10"=>0, "2016-11"=>0, "2016-12"=>1}}

        output_hash = process_and_build_output_hash
        assert_equal 2, output_hash[:datasets].size
        started = output_hash[:datasets][0]
        assert_equal started[:label], 'Started'
        completed = output_hash[:datasets][1]
        assert_equal completed[:label], 'Completed'

        assert_equal [2,0,0], started[:data]
        assert_equal [0,0,1], completed[:data]
      end
    end

    should "create a base output hash of data for a single item with double digit month input" do
      @work_items = [WorkItem.new(:start_date => "07/01/16", :complete_date => "15/01/16")]
      @data = {:started => {"2016-01"=>1, "2016-02"=>0}, :completed => {"2016-01"=>0, "2016-02"=>1}}
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
      @data = {:started => {"2016-51"=>1, "2016-52"=>0, "2017-01"=>0, "2017-02"=>0}, :completed => {"2016-51"=>0, "2016-52"=>0, "2017-01"=>0, "2017-02"=>1}}
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
        @data = {:started => {"2016-10"=>11, "2016-11"=>0, "2016-12"=>0}, :completed => {"2016-10"=>0, "2016-11"=>0, "2016-12"=>11}}
        output_hash = process_and_build_output_hash

        assert_equal 1, output_hash[:options].size
        assert_equal 0, output_hash[:options][:scales][:yAxes][0][:ticks][:min]
        assert_equal 2, output_hash[:options][:scales][:yAxes][0][:ticks][:stepSize]
        assert_equal 20, output_hash[:options][:scales][:yAxes][0][:ticks][:max]
        assert_equal false, output_hash[:options][:scales][:yAxes][0][:stacked]

      end

      should "set options with multiple steps for with max < 100" do
        @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")] * 81
        @data = {:started => {"2016-10"=>81, "2016-11"=>0, "2016-12"=>0}, :completed => {"2016-10"=>0, "2016-11"=>0, "2016-12"=>81}}
        output_hash = process_and_build_output_hash

        assert_equal 1, output_hash[:options].size
        assert_equal 0, output_hash[:options][:scales][:yAxes][0][:ticks][:min]
        assert_equal 9, output_hash[:options][:scales][:yAxes][0][:ticks][:stepSize]
        assert_equal 90, output_hash[:options][:scales][:yAxes][0][:ticks][:max]
        assert_equal false, output_hash[:options][:scales][:yAxes][0][:stacked]

      end

      should "set options with multiple steps for with max > 100" do
        @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")] * 112
        @data = {:started => {"2016-10"=>112, "2016-11"=>0, "2016-12"=>0}, :completed => {"2016-10"=>0, "2016-11"=>0, "2016-12"=>112}}
        output_hash = process_and_build_output_hash

        assert_equal 1, output_hash[:options].size
        assert_equal 0, output_hash[:options][:scales][:yAxes][0][:ticks][:min]
        assert_equal 12, output_hash[:options][:scales][:yAxes][0][:ticks][:stepSize]
        assert_equal 120, output_hash[:options][:scales][:yAxes][0][:ticks][:max]
        assert_equal false, output_hash[:options][:scales][:yAxes][0][:stacked]

      end
    end

    should "create output" do
      widget = StartedVsCompletedWidgetRenderer.new
      widget.prepare @work_items, nil, @data

      send_event = MiniTest::Mock.new
      send_event.expect :call, nil, ['started_vs_completed', widget.build_output_hash]
      widget.stub :send_event, send_event do
        widget.output
      end

      send_event.verify
    end
  end

  private def process_and_build_output_hash
    widget = StartedVsCompletedWidgetRenderer.new
    widget.prepare @work_items, nil, @data

    widget.build_output_hash
  end
end