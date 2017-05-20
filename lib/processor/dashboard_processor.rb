

class DashboardProcessor

  def initialize(data_reader, config_reader, renderers, data_processors)
    @data_reader     = data_reader
    @config_reader   = config_reader
    @renderers       = renderers
    @data_processors = data_processors
  end


  def process_dashboards
    work_items = @data_reader.read_data
    config = @config_reader.read_config
    data = Hash.new

    @data_processors.each { |data_processor|
      data = data.merge(data_processor.process(work_items, config, data))
    }
    @renderers.each { |renderer|
      renderer.prepare(work_items, config, data)
      renderer.output
    }
  end

end