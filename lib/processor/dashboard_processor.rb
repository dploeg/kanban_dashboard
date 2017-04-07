

class DashboardProcessor

  def initialize(data_reader, config_reader, widget_processors, data_processors)
    @data_reader = data_reader
    @config_reader = config_reader
    @widget_processors = widget_processors
    @data_processors = data_processors
  end


  def process_dashboards
    work_items = @data_reader.read_data
    config = @config_reader.read_config
    data = Hash.new

    @data_processors.each { |data_processor|
      data.merge(data_processor.process(work_items, config))
    }

    @widget_processors.each { |widget|
      widget.process(work_items, config, data)
      widget.output
    }
  end

end