

class DataProcessor

  def initialize(data_reader, config_reader, widget_processors)
    @data_reader = data_reader
    @config_reader = config_reader
    @widget_processors = widget_processors
  end


  def process_data
    work_items = @data_reader.read_data
    config = @config_reader.read_config

    @widget_processors.each { |widget|
      widget.process(work_items, config)
      widget.output
    }
  end

end