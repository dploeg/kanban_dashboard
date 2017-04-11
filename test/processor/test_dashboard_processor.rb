require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../lib/processor/dashboard_processor'
require_relative '../../lib/model/work_item'

class TestDashboardProcessor < Minitest::Test

  context 'DataProcessor' do

    setup do
      @data_counter = 1
      @data_key_counter = 1
      @data = Hash.new
      setup_work_items
      setup_readers
      setup_data_processors
      setup_widget_processors
    end

    should 'read data from file' do
      @processor = DashboardProcessor.new(@data_reader, @config_reader, @widget_processors, @data_processors)
      @processor.process_dashboards

      @data_reader.verify
      @config_reader.verify
      @first_data_processor.verify
      @second_data_processor.verify
      @first_widget_processor.verify
      @second_widget_processor.verify
    end

  end

  private def setup_readers
    @data_reader = MiniTest::Mock.new
    @config_reader = MiniTest::Mock.new
    @data_reader.expect :read_data, @work_items
    @config_reader.expect :read_config, @config
  end

  private def setup_data_processors
    @first_data_processor = MiniTest::Mock.new
    @second_data_processor = MiniTest::Mock.new
    @data = @data.merge(process_data_items(@first_data_processor))
    @data = @data.merge(process_data_items(@second_data_processor))

    @data_processors = [@first_data_processor, @second_data_processor]
  end

  private def setup_widget_processors
    @first_widget_processor = MiniTest::Mock.new
    @second_widget_processor = MiniTest::Mock.new
    process_work_items(@first_widget_processor)
    process_work_items(@second_widget_processor)

    @widget_processors = [@first_widget_processor, @second_widget_processor]
  end

  private def process_work_items(widget_processor)
    widget_processor.expect :prepare, nil, [@work_items, @config, @data]
    widget_processor.expect :output, nil
  end

  private def process_data_items(data_processor)
    data = {@data_key_counter.alph => @data_counter}
    data_processor.expect :process, data, [@work_items, @config, @data]
    @data_counter+=1
    @data_key_counter+=1
    data
  end

  private def setup_work_items
    @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"),
                   WorkItem.new(:start_date => "15/3/16", :complete_date => "21/3/16")]
    @config = {:forecast_config => {:start_date => "10/3/16", :min_number_of_stories => 30, :max_number_of_stories => 50}}
  end

end

class Numeric
  Alph = ("a".."z").to_a

  def alph
    s, q = "", self
    (q, r = (q - 1).divmod(26)); s.prepend(Alph[r]) until q.zero?
    s
  end
end