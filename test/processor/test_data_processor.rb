require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../lib/processor/data_processor'

class TestDataProcessor < Minitest::Test

  def setup_readers
    @reader = MiniTest::Mock.new
    @reader.expect :read_data, nil
    @reader.expect :work_items, @work_items
  end

  def setup_widget_processors
    @first_widget_processor = MiniTest::Mock.new
    @second_widget_processor = MiniTest::Mock.new
    process_work_items(@first_widget_processor)
    process_work_items(@second_widget_processor)

    @widget_processors = [@first_widget_processor, @second_widget_processor]
  end

  def process_work_items(widget_processor)
    widget_processor.expect :process, nil, [@work_items]
    widget_processor.expect :output, nil
  end

  def setup_work_items
    @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"),
                   WorkItem.new(:start_date => "15/3/16", :complete_date => "21/3/16")]
  end

  context 'DataProcessor' do

    setup do
      setup_work_items
      setup_readers
      setup_widget_processors
    end

    should 'read data from file' do
      @processor = DataProcessor.new(@reader, @widget_processors)
      @processor.process_data

      @reader.verify
      @first_widget_processor.verify
      @second_widget_processor.verify
    end

  end

end