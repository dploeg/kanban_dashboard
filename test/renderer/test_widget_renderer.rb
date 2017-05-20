require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../lib/model/work_item'
require_relative '../../lib/renderer/widget_renderer'

class TestWidgetRenderer < Minitest::Test

  context 'WidgetProcessor' do

    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")]
    end

    should "send output for a given name" do
      name = 'my_name'
      widget = WidgetRenderer.new(name)
      widget.prepare @work_items

      send_event = MiniTest::Mock.new
      send_event.expect :call, nil, [name, widget.build_output_hash]
      widget.stub :send_event, send_event do
        widget.output
      end

      send_event.verify
    end

  end

end