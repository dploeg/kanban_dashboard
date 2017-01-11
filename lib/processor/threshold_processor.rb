
class ThresholdProcessor

  def initialize(threshold_reader, threshold_value_processors)
    @threshold_reader = threshold_reader
    @threshold_processors = threshold_value_processors
  end

  def process(work_items)
    thresholds = @threshold_reader.read_thresholds
    warnings = Array.new
    @threshold_processors.each { |threshold_value_processor|
      warnings.push(threshold_value_processor.process(work_items, *thresholds[threshold_value_processor.name]))
    }
    warnings.flatten
  end


end