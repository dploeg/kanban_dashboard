

class DataProcessor

  def initialize(reader, widget_processors)
    @reader = reader
    @widget_processors = widget_processors
  end


  def process_data
    work_items = @reader.read_data

    @widget_processors.each { |widget|
      widget.process(work_items)
      widget.output
    }
  end

end