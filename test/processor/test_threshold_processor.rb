require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../lib/processor/threshold_processor'
require_relative '../../lib/model/threshold_warning'
require_relative '../../lib/model/threshold'
require_relative '../../lib/model/work_item'

class TestThresholdProcessor < Minitest::Test

  context 'TestThresholdProcessor' do

    setup do
      @threshold_warning1 = ThresholdWarning.new("Started vs Completed", "has exceeded threshold of 5")
      @threshold_warning2 = [ThresholdWarning.new("95 Percentile - Standard", "has exceeded threshold of 15"),
                             ThresholdWarning.new("95 Percentile - Expedite", "has exceeded threshold of 5")]
      @threshold_warning1 = ["Warning 1"]
      @threshold_warning2 = ["Warning 2", "Warning 3"]
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"),
                     WorkItem.new(:start_date => "15/3/16", :complete_date => "21/3/16")]
      @threshold1 = Threshold.new(:type => Threshold::UPPER, :value => 95, :processor => "first")
      @threshold2 = Threshold.new(:type => Threshold::DIFF, :value => 5, :processor => "second")
      @threshold_map = {'first' => @threshold1, 'second' => @threshold2}
      create_mocks
    end

    should "defer to threshold processors and collate results" do
      threshold_processor = ThresholdProcessor.new(@threshold_reader, [@first_threshold_processor, @second_threshold_processor])
      @threshold_reader.expect :read_thresholds, @threshold_map
      @first_threshold_processor.expect :name, "first"
      @second_threshold_processor.expect :name, "second"
      @first_threshold_processor.expect :process, @threshold_warning1, [@work_items, @threshold1]
      @second_threshold_processor.expect :process, @threshold_warning2, [@work_items, @threshold2]

      warnings = threshold_processor.process(@work_items)
      verify_base_expectations(warnings)
    end

    should "process thresholds for different classes of service" do
      @threshold3 = Threshold.new(:type => Threshold::UPPER, :value => 20, :class_of_service => "Standard", :processor => "first")
      @threshold4 = Threshold.new(:type => Threshold::UPPER, :value => 15, :class_of_service => "Fixed Date", :processor => "first")
      @threshold5 = Threshold.new(:type => Threshold::UPPER, :value => 5, :class_of_service => "Expedite", :processor => "first")
      @threshold6 = Threshold.new(:type => Threshold::DIFF, :value => 5, :class_of_service => "Standard", :processor => "second")

      @threshold_map = {'first' => [@threshold3, @threshold4, @threshold5], 'second' => [@threshold6]}

      threshold_processor = ThresholdProcessor.new(@threshold_reader, [@first_threshold_processor, @second_threshold_processor])
      @threshold_reader.expect :read_thresholds, @threshold_map
      @first_threshold_processor.expect :name, "first"
      @second_threshold_processor.expect :name, "second"
      @first_threshold_processor.expect :process, @threshold_warning1, [@work_items, [@threshold3, @threshold4, @threshold5]]
      @second_threshold_processor.expect :process, @threshold_warning2, [@work_items, [@threshold6]]

      warnings = threshold_processor.process(@work_items)

      verify_base_expectations(warnings)

    end
  end

  private def verify_base_expectations(warnings)
    @first_threshold_processor.verify
    @second_threshold_processor.verify

    assert_equal [@threshold_warning1, @threshold_warning2].flatten, warnings
  end


  private def create_mocks
    @first_threshold_processor = MiniTest::Mock.new
    @second_threshold_processor = MiniTest::Mock.new
    @threshold_reader = MiniTest::Mock.new
  end
end
