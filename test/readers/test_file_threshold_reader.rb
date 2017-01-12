require 'minitest/autorun'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../lib/model/threshold'
require_relative '../../lib/readers/file_threshold_reader'

class TestFileThresholdReader < Minitest::Test

  context 'FileThresholdReader' do

      should 'do nothing with an file with no data' do
        reader = FileThresholdReader.new('test/fixtures/files/no_data_in_file.json')
        reader.read_thresholds
        assert_equal 0, reader.thresholds.size
      end

      should 'read in file data with thresholds and class of service' do
        reader = FileThresholdReader.new('test/fixtures/files/sample_thresholds.json')
        reader.read_thresholds
        thresholds = reader.thresholds
        assert_equal 2, thresholds.size
        assert_equal 1, thresholds['first'].size
        assert_equal 2, thresholds['second'].size
        assert_equal Threshold.new(:type => Threshold::UPPER, :value => 10, :class_of_service => "Standard", :processor => "first"), thresholds['first'][0]
        assert_equal Threshold.new(:type => Threshold::LOWER, :value => 2, :class_of_service => "Expedite", :processor => "second"), thresholds['second'][0]
        assert_equal Threshold.new(:type => Threshold::UPPER, :value => 12, :processor => "second"), thresholds['second'][1]

      end

      should 're-reading should reset the array' do
        reader = FileThresholdReader.new('test/fixtures/files/sample_thresholds.json')
        reader.read_thresholds
        reader.read_thresholds
        thresholds = reader.thresholds
        assert_equal 2, thresholds.size
      end

      should 'throw exception if the file is empty' do
        reader = FileThresholdReader.new('test/fixtures/files/empty_file.json')
        assert_raises RuntimeError do
          reader.read_thresholds
        end
      end

    end
end


