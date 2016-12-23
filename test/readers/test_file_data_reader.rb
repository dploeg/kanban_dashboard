require 'minitest/autorun'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../lib/readers/file_data_reader'

class TestFileDataReader < Minitest::Test

  context 'FileDataReader' do

    should 'do nothing with an file with no data' do
      reader = FileDataReader.new('test/fixtures/files/no_data_in_file.json')
      reader.read_data
      assert_equal 0, reader.work_items.size
    end

    should 'read in file data with dates' do
      reader = FileDataReader.new('test/fixtures/files/sample_data.json')
      reader.read_data
      input_data = reader.work_items
      assert_equal 3, input_data.size
      assert_equal "15/3/16", input_data[1].start_date
      assert_equal "21/3/16", input_data[1].complete_date
    end

    should 'throw exception if the file is empty' do
      reader = FileDataReader.new('test/fixtures/files/empty_file.json')
      assert_raises RuntimeError do
        reader.read_data
      end
    end

  end

end