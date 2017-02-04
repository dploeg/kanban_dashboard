require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/processor/threshold/current_items_threshold_value_processor'
require_relative '../../../lib/model/work_item'
require_relative '../../../lib/processor/processor_utils'
require_relative '../../../lib/model/threshold'

class TestCurrentItemsThresholdValueProcessor < Minitest::Test

    context 'CurrentItemsThresholdValueProcessor' do
      setup do
        @work_items = [WorkItem.new(:start_date => (Date.today - 5).strftime(WorkItem::DATE_FORMAT))]
        @threshold1 = Threshold.new(:type => Threshold::UPPER, :value => 10, :processor => "current_items")
        @threshold2 = Threshold.new(:type => Threshold::UPPER, :value => 4,  :processor => "current_items")
        @threshold3 = Threshold.new(:type => Threshold::UPPER, :value => 7,  :processor => "current_items", :class_of_service => 'Standard')
        @threshold4 = Threshold.new(:type => Threshold::UPPER, :value => 3,  :processor => "current_items", :class_of_service => 'Expedite')
        @threshold5 = Threshold.new(:type => Threshold::LOWER, :value => 12, :processor => "current_items")

      end

      should "initialise name" do
        processor = CurrentItemsThresholdValueProcessor.new

        assert_equal ProcessorUtils::CURRENT_ITEMS_THRESHOLD_VALUE_PROCESSOR, processor.name
      end


      context 'single item' do
        should 'not exceeded threshold if no thresholds given' do
          processor = CurrentItemsThresholdValueProcessor.new
          warnings = processor.process(@work_items, *[])

          assert_equal 0, warnings.size
        end

        should 'not exceeded threshold if its a lower control limit (that don\' make no sense)' do
          processor = CurrentItemsThresholdValueProcessor.new
          warnings = processor.process(@work_items, *[@threshold5])

          assert_equal 0, warnings.size
        end

        should 'not exceeded threshold if its under the threshold value' do
          processor = CurrentItemsThresholdValueProcessor.new
          warnings = processor.process(@work_items, *[@threshold1])

          assert_equal 0, warnings.size
        end

        should 'not exceed threshold if its completed' do
          @work_items = [WorkItem.new(:start_date => "13/02/16", :complete_date => "27/02/16", :class_of_service => 'Standard')]
          processor = CurrentItemsThresholdValueProcessor.new
          warnings = processor.process(@work_items, *[@threshold2])

          assert_equal 0, warnings.size
        end

        should 'not exceed class of service threshold if its completed' do
          @work_items = [WorkItem.new(:start_date => "13/02/16", :complete_date => "27/02/16", :class_of_service => 'Standard')]
          processor = CurrentItemsThresholdValueProcessor.new
          warnings = processor.process(@work_items, *[@threshold3])

          assert_equal 0, warnings.size
        end

        should 'Exceeded threshold' do
          processor = CurrentItemsThresholdValueProcessor.new
          warnings = processor.process(@work_items, *[@threshold2])

          assert_equal 1, warnings.size
          assert_equal "In Progress time (incomplete items)", warnings[0].label
          assert_equal "has exceeded the upper control limit threshold of 4 days for 1 item", warnings[0].value
        end

      end

      context 'multiple items' do

        should 'handle multiple items exceeding threshold' do
          @work_items = [WorkItem.new(:start_date => (Date.today - 5).strftime(WorkItem::DATE_FORMAT), :class_of_service => 'Standard'),
                         WorkItem.new(:start_date => (Date.today - 6).strftime(WorkItem::DATE_FORMAT), :class_of_service => 'Expedite')]
          processor = CurrentItemsThresholdValueProcessor.new
          warnings = processor.process(@work_items, *[@threshold2])

          assert_equal 1, warnings.size
          assert_equal "In Progress time (incomplete items)", warnings[0].label
          assert_equal "has exceeded the upper control limit threshold of 4 days for 2 items", warnings[0].value
        end

        should 'handle single item breaching threshold with multiple items in list' do
          @work_items = [WorkItem.new(:start_date => (Date.today - 12).strftime(WorkItem::DATE_FORMAT)),
                         WorkItem.new(:start_date => (Date.today - 6).strftime(WorkItem::DATE_FORMAT))]
          processor = CurrentItemsThresholdValueProcessor.new
          warnings = processor.process(@work_items, *[@threshold1])

          assert_equal 1, warnings.size
          assert_equal "In Progress time (incomplete items)", warnings[0].label
          assert_equal "has exceeded the upper control limit threshold of 10 days for 1 item", warnings[0].value
        end

        should 'handle multiple classes of service' do
          @work_items = [WorkItem.new(:start_date => (Date.today - 8).strftime(WorkItem::DATE_FORMAT), :class_of_service => 'Standard'),
                         WorkItem.new(:start_date => (Date.today - 6).strftime(WorkItem::DATE_FORMAT), :class_of_service => 'Expedite')]
          processor = CurrentItemsThresholdValueProcessor.new
          warnings = processor.process(@work_items, *[@threshold1, @threshold3, @threshold4])

          assert_equal 2, warnings.size
          assert_equal "In Progress time (incomplete items) - Standard", warnings[0].label
          assert_equal "has exceeded the upper control limit threshold of 7 days for 1 item", warnings[0].value
          assert_equal "In Progress time (incomplete items) - Expedite", warnings[1].label
          assert_equal "has exceeded the upper control limit threshold of 3 days for 1 item", warnings[1].value
        end

        should 'handle items for multiple classes of service' do
          @work_items = [WorkItem.new(:start_date => (Date.today - 8).strftime(WorkItem::DATE_FORMAT), :class_of_service => 'Standard'),
                         WorkItem.new(:start_date => (Date.today - 9).strftime(WorkItem::DATE_FORMAT), :class_of_service => 'Standard'),
                         WorkItem.new(:start_date => (Date.today - 6).strftime(WorkItem::DATE_FORMAT), :class_of_service => 'Expedite'),
                         WorkItem.new(:start_date => (Date.today - 7).strftime(WorkItem::DATE_FORMAT), :class_of_service => 'Expedite')]
          processor = CurrentItemsThresholdValueProcessor.new
          warnings = processor.process(@work_items, *[@threshold1, @threshold3, @threshold4])

          assert_equal 2, warnings.size
          assert_equal "In Progress time (incomplete items) - Standard", warnings[0].label
          assert_equal "has exceeded the upper control limit threshold of 7 days for 2 items", warnings[0].value
          assert_equal "In Progress time (incomplete items) - Expedite", warnings[1].label
          assert_equal "has exceeded the upper control limit threshold of 3 days for 2 items", warnings[1].value
        end

      end
    end
end