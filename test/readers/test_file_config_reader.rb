require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../lib/readers/file_config_reader'

class TestFileConfigReader < Minitest::Test

    context 'FileConfigReader' do

      should 'raise exception where file does not exist' do
        reader = FileConfigReader.new('test/fixtures/files/config/file_does_not_exist.yaml')
        assert_raises RuntimeError do
          reader.read_config
        end
      end

      should 'return an empty hash for empty file' do
        reader = FileConfigReader.new('test/fixtures/files/config/empty_config.yaml')
        config = reader.read_config
        assert_equal 0, config.size
      end

      should 'return configuration hash' do
        reader = FileConfigReader.new('test/fixtures/files/config/sample_config.yaml')
        config = reader.read_config
        expected = {:migration =>{:customer =>"Example Customer", :test =>false}, :sources =>[{:name =>"Use the Source", :engine =>"Foo"}, {:name =>"Sourcey", :engine =>"Bar"}]}
        assert_equal expected, config
      end

      should 'read a multi-level hash with risk values' do
        reader = FileConfigReader.new('test/fixtures/files/config/risk_config.yaml')
        config = reader.read_config
        expected = {:forecast_config =>{:start_date =>"10/3/16", :min_number_of_stories =>30, :max_number_of_stories =>30,
                                        :story_split_rate_low=> 1.0, :story_split_rate_high =>  1.0, :target_complete_date => "25/5/16",
                                        :risks => [{:likelihood => 20, :impact_low => 5, :impact_high=> 10},
                                                   {:likelihood => 30, :impact_low => 20, :impact_high=> 30},
                                                   {:likelihood => 75, :impact_low => 10, :impact_high=> 15}]
        }}
        assert_equal expected, config

      end
    end
end