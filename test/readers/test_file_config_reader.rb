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

    end
end