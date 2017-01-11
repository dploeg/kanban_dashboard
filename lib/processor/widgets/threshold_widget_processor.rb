require 'dashing/app'

class ThresholdWidgetProcessor

  def initialize(threshold_processor)
    @threshold_processor = threshold_processor
  end

  def process(work_items)
    @warnings = @threshold_processor.process(work_items)
  end

  def output
    send_event('threshold', build_output_hash)
  end

  def build_output_hash
    output = Hash.new

    items = Array.new
    @warnings.each { | warning|
      items.push("label" => warning.label, "value" => warning.value)
    }
    output['items'] = items
    output
  end
end