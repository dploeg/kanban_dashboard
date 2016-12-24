require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/processor/widgets/LeadTimeWidgetProcessor'

class TestDataProcessor < Minitest::Test

  context 'LeadTimeWidgetProcessor' do

    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"),
                     WorkItem.new(:start_date => "15/3/16", :complete_date => "21/3/16"),
                     WorkItem.new(:start_date => "12/3/16", :complete_date => "14/4/16"),
                     WorkItem.new(:start_date => "19/3/16", :complete_date => "19/4/16"),
                     WorkItem.new(:start_date => "21/3/16", :complete_date => "17/4/16"),
                     WorkItem.new(:start_date => "28/3/16", :complete_date => "22/4/16"),
                     WorkItem.new(:start_date => "2/4/16", :complete_date => "25/4/16"),
                     WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16"),
      ]

    end

    should 'process 95th percentile for widget' do
      widget = LeadTimeWidgetProcessor.new
      widget.process @work_items

      assert_equal 32, widget.lead_time_95th_percentile
    end

    should 'output percentile' do
      widget = LeadTimeWidgetProcessor.new
      widget.process @work_items



      widget.output


    end

  end


end
