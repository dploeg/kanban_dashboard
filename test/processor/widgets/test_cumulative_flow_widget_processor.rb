require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/model/work_item'
require_relative '../../test_constants'
require_relative '../../../lib/processor/widgets/cumulative_flow_widget_processor'
require_relative '../../../test/processor/widgets/started_vs_finished_test_helper'

class TestCumulativeFlowWidgetProcessor < Minitest::Test
  include TestConstants, StartedVsFinishedTestHelper

  context 'CumulativeFlowWidgetProcessor' do

    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")]
    end

    should "create a base output hash for a single item" do
      output_hash = process_and_build_output_hash
      assert_equal 2, output_hash['datasets'].size
      started = output_hash['datasets'][0]
      assert_equal started['label'], 'Started'
      completed = output_hash['datasets'][1]
      assert_equal completed['label'], 'Completed'

      assert_equal [1,1,1], started['data']
      assert_equal [0,0,1], completed['data']

    end

    should "create output" do
      widget = CumulativeFlowWidgetProcessor.new
      widget.process @work_items

      send_event = MiniTest::Mock.new
      send_event.expect :call, nil, ['cumulative_flow', widget.build_output_hash]
      widget.stub :send_event, send_event do
        widget.output
      end

      send_event.verify
    end

    should "color started and completed for a single item" do
      output_hash = process_and_build_output_hash

      check_formatting_started(output_hash['datasets'][0])
      check_formatting_completed(output_hash['datasets'][1])
    end

    should "set labels for a single item" do
      output_hash = process_and_build_output_hash

      check_labels(output_hash)
    end

    should "set options for a single item" do
      expected = {
          scales: {
              yAxes: [{
                          stacked: true
                      }]
          }
      }
      output_hash = process_and_build_output_hash

      assert_equal expected, output_hash['options']
    end

  end

  private def process_and_build_output_hash
    widget = CumulativeFlowWidgetProcessor.new
    widget.process @work_items

    widget.build_output_hash
  end
end