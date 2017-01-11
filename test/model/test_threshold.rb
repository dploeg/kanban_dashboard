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

  end

end

