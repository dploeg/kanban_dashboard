require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../lib/model/work_item'
require_relative '../../lib/renderer/base_renderer'

class TestRenderer < Minitest::Test

  context 'Renderer' do

    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")]
    end

    should "send output for a given name" do
      name = 'my_name'
      renderer = BaseRenderer.new(name)
      renderer.prepare @work_items

      send_event = MiniTest::Mock.new
      send_event.expect :call, nil, [name, renderer.build_output_hash]
      renderer.stub :send_event, send_event do
        renderer.output
      end

      send_event.verify
    end

  end

end