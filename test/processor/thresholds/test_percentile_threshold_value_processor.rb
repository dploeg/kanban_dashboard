require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'


class TestPercentileThresholdValueProcessor < Minitest::Test

  context 'TestPercentileThresholdValueProcessor' do

    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"),
                     WorkItem.new(:start_date => "15/3/16", :complete_date => "21/3/16")]
      @threshold1 = Threshold.new(:type => Threshold::UPPER, :value => 10, :processor => "first")
      @threshold2 = Threshold.new(:type => Threshold::UPPER, :value => 11, :processor => "first")
      @threshold3 = Threshold.new(:type => Threshold::UPPER, :value => 9, :processor => "first")
      @threshold4 = Threshold.new(:type => Threshold::LOWER, :value => 11, :processor => "first")

    end

    should "not return anything if threshold not reached" do
      processor = PercentileThresholdValueProcessor.new
      warnings = processor.process(@work_items, *[@threshold1, @threshold2])

      assert_equal 0, warnings.size
    end

    should "return something if upper threshold reached" do
      processor = PercentileThresholdValueProcessor.new
      warnings = processor.process(@work_items, @threshold3)

      assert_equal 1, warnings.size
      assert_equal "Lead Time 95 percentile", warnings[0].label
      assert_equal "has exceeded upper control limit threshold of 9 with value of 10", warnings[0].value
    end

    should "return something if lower threshold reached" do
      processor = PercentileThresholdValueProcessor.new
      warnings = processor.process(@work_items, @threshold4)

      assert_equal 1, warnings.size
      assert_equal "Lead Time 95 percentile", warnings[0].label
      assert_equal "has exceeded lower control limit threshold of 11 with value of 10", warnings[0].value
    end

    should "process multiple items for class of service" do

    end

  end


end
