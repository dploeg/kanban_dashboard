require 'minitest/autorun'
require 'shoulda/matchers'
require 'shoulda/context'


class TestSomethng < Minitest::Test


  context 'something' do
    should 'do something' do
      assert_equal 4, 4
    end
  end
end