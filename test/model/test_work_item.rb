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

    should 'generate to_s' do
      work_item = WorkItem.new(:start_date => "15/10/16", :complete_date => "5/11/16", :class_of_service => "Fixed Date")
      assert_equal "Start Date: 15/10/16, Complete Date: 5/11/16, Class of Service: Fixed Date", work_item.to_s
    end

    should 'mark lead time as one where lead time is zero' do
      work_item = WorkItem.new(:start_date => "15/10/16", :complete_date => "15/10/16")
      assert_equal 1, work_item.lead_time
    end

    should 'create start week string' do
      work_item = WorkItem.new(:start_date => "15/10/16", :complete_date => "5/11/16")
      assert_equal '2016-41', work_item.start_week_string
    end

    should 'create end week string' do
      work_item = WorkItem.new(:start_date => "15/10/16", :complete_date => "5/11/16")
      assert_equal '2016-44', work_item.complete_week_string
    end

  end

end

