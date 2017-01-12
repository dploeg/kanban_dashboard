require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/model/work_item'
require_relative '../../../lib/processor/data/started_vs_finished_data_processor'
require_relative '../../../lib/processor/widgets/net_flow_widget_processor'

class TestNetFlowWidgetProcessor < Minitest::Test

  context 'NetFlowWidgetProcessor' do

    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")]
    end

    should "create a base output hash of data for a single item" do
      output_hash = process_and_build_output_hash
      assert_equal 1, output_hash['datasets'].size
      flow = output_hash['datasets'][0]
      assert_equal flow['label'], 'Net Flow'

      assert_equal [-1,0,1], flow['data']
    end

    should "set labels for a single item" do
      output_hash = process_and_build_output_hash

      labels = output_hash['labels']
      assert_equal 3, labels.size
      assert_equal "2016-10", labels[0]
      assert_equal "2016-11", labels[1]
      assert_equal "2016-12", labels[2]
    end

    should "color flow for a single item" do
      output_hash = process_and_build_output_hash

      flow = output_hash['datasets'][0]
      flow_index = 0
      flow['data'].each{|flow_value|
        if flow_value < 0
          assert_equal 'rgba(255, 99, 132, 0.2)', flow['backgroundColor'][flow_index]
          assert_equal 'rgba(255, 99, 132, 1)', flow['borderColor'][flow_index]
        else
          assert_equal 'rgba(92, 255, 127, 0.2)', flow['backgroundColor'][flow_index]
          assert_equal 'rgba(92, 255, 127, 1)', flow['borderColor'][flow_index]
        end
        flow_index+=1
      }
      assert_equal 1, flow['borderWidth']

    end

    should "create output" do
      widget = NetFlowWidgetProcessor.new
      widget.process @work_items

      send_event = MiniTest::Mock.new
      send_event.expect :call, nil, ['net_flow', widget.build_output_hash]
      widget.stub :send_event, send_event do
        widget.output
      end

      send_event.verify
    end

  end

  private def process_and_build_output_hash
    widget = NetFlowWidgetProcessor.new
    widget.process @work_items

    widget.build_output_hash
  end

end

