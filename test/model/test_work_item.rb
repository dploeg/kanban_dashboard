require 'minitest/autorun'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../lib/model/work_item'

class TestWorkItem < Minitest::Test

  context 'WorkItem' do

    should 'calculate simple lead time' do
      work_item = WorkItem.new(:start_date => "15/10/16", :complete_date => "21/10/16")

      assert_equal 6, work_item.lead_time
    end

    should 'calculate date lead time' do
      work_item = WorkItem.new(:start_date => "15/10/16", :complete_date => "5/11/16")

      assert_equal 21, work_item.lead_time
    end


  end

end

