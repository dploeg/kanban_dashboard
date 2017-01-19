require 'minitest/autorun'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/model/work_item'
require_relative '../../../lib/readers/work_item/file_work_item_reader'

class TestFileWorkItemReader < Minitest::Test

  context 'FileWorkItemReader' do

    should 'do nothing with an file with no data' do
      reader = FileWorkItemReader.new('test/fixtures/files/no_data_in_file.json')
      reader.read_data
      assert_equal 0, reader.work_items.size
    end

    should 'read in file data with dates and class of service' do
      reader = FileWorkItemReader.new('test/fixtures/files/sample_data.json')
      reader.read_data
      input_data = reader.work_items
      assert_equal 3, input_data.size
      assert_equal "15/3/16", input_data[1].start_date
      assert_equal "21/3/16", input_data[1].complete_date
      assert_equal "Fixed Date", input_data[1].class_of_service
    end

    should 're-reading should reset the array' do
      reader = FileWorkItemReader.new('test/fixtures/files/sample_data.json')
      reader.read_data
      reader.read_data
      input_data = reader.work_items
      assert_equal 3, input_data.size
    end

    should 'throw exception if the file is empty' do
      reader = FileWorkItemReader.new('test/fixtures/files/empty_file.json')
      assert_raises RuntimeError do
        reader.read_data
      end
    end

  end

end