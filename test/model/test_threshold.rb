require 'minitest/autorun'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../lib/model/threshold'

class TestWorkItem < Minitest::Test

  context 'Threshold' do

    should "set upper as defult" do
      threshold = Threshold.new([])
      assert_equal Threshold::UPPER, threshold.type
    end

    should "build to_s value" do
      processor_name = "current_items"
      value = 7
      threshold = Threshold.new(:type => Threshold::UPPER, :value => value, :processor => processor_name, :class_of_service => 'Standard')
      assert_equal "Threshold(Type: %s, value: %d, class_of_service: %s, processor: %s, object_id: %s)" %
                       [Threshold::UPPER, value, threshold.class_of_service, processor_name, "0x00%x" % (threshold.object_id << 1)],
                   threshold.to_s
    end

  end

end

