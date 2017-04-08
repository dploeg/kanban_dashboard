require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/model/work_item'

class TestStartedVsCompletedDataProcessor < Minitest::Test

    context 'process' do

      setup do
        @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")]
      end

      should 'populate started and completed data' do
        processor = StartedVsCompletedDataProcessor.new
        data = processor.process @work_items, nil, Hash.new

        started = {"2016-10" => 1, "2016-11" => 0, "2016-12" => 0}
        completed = {"2016-10" => 0, "2016-11" => 0, "2016-12" => 1}
        assert_equal started, data[:started]
        assert_equal completed, data[:completed]
        assert_equal 2, data.size
      end
    end
end