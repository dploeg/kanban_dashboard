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
      assert_equal "Lead Time 95 percentile - Standard", warnings[0].label
      assert_equal "has exceeded upper control limit threshold of 9 with value of 10", warnings[0].value
    end

    should "return something if lower threshold reached" do
      processor = PercentileThresholdValueProcessor.new
      warnings = processor.process(@work_items, @threshold4)

      assert_equal 1, warnings.size
      assert_equal "Lead Time 95 percentile - Standard", warnings[0].label
      assert_equal "has exceeded lower control limit threshold of 11 with value of 10", warnings[0].value
    end

    should "process multiple items for different classes of service" do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"),
                           WorkItem.new(:start_date => "15/3/16", :complete_date => "21/3/16"),
                           WorkItem.new(:start_date => "12/3/16", :complete_date => "14/4/16"),
                           WorkItem.new(:start_date => "19/3/16", :complete_date => "19/4/16"),
                           WorkItem.new(:start_date => "21/3/16", :complete_date => "17/4/16"),
                           WorkItem.new(:start_date => "28/3/16", :complete_date => "22/4/16"),
                           WorkItem.new(:start_date => "2/4/16", :complete_date => "25/4/16", :class_of_service => TestConstants::STANDARD),
                           WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16"),

                           WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16", :class_of_service => TestConstants::EXPEDITE),
                           WorkItem.new(:start_date => "2/4/16", :complete_date => "13/4/16", :class_of_service => TestConstants::FIXED_DATE),
                           WorkItem.new(:start_date => "5/4/16", :complete_date => "25/4/16", :class_of_service => TestConstants::INTANGIBLE),
                           WorkItem.new(:start_date => "6/4/16", :complete_date => "13/4/16", :class_of_service => TestConstants::EXPEDITE),
                           WorkItem.new(:start_date => "7/4/16", :complete_date => "14/4/16", :class_of_service => TestConstants::EXPEDITE),
                           WorkItem.new(:start_date => "6/4/16", :complete_date => "28/4/16", :class_of_service => TestConstants::FIXED_DATE),
                           WorkItem.new(:start_date => "13/4/16", :complete_date => "12/5/16", :class_of_service => TestConstants::INTANGIBLE)]
      @threshold5 = Threshold.new(:type => Threshold::UPPER, :value => 7, :processor => "first", :class_of_service => TestConstants::EXPEDITE)

      processor = PercentileThresholdValueProcessor.new
      warnings = processor.process(@work_items, *[@threshold3, @threshold5])

      assert_equal 2, warnings.size
      assert_equal "Lead Time 95 percentile - Standard", warnings[0].label
      assert_equal "has exceeded upper control limit threshold of 9 with value of 32", warnings[0].value
      assert_equal "Lead Time 95 percentile - Expedite", warnings[1].label
      assert_equal "has exceeded upper control limit threshold of 7 with value of 8", warnings[1].value
    end

    should "accept optional percentile value for constructor" do
      processor = PercentileThresholdValueProcessor.new(85)

      assert_equal 85, processor.percentile
    end

  end


end
