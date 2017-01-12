require 'dashing/app'
require_relative '../../../lib/processor/widgets/widget_processor'

class ThresholdWidgetProcessor < WidgetProcessor

  def initialize(threshold_processor)
    super('thresholds')
    @threshold_processor = threshold_processor
  end

  def process(work_items)
    @warnings = @threshold_processor.process(work_items)
  end

  def build_output_hash
    output = Hash.new

    items = Array.new
    @warnings.each { | warning|
      items.push("label" => warning.label, "value" => warning.value)
    }
    output['items'] = items
    if @warnings.size > 0
      output['status'] = "warning"
    else
      output['status'] = "clear"
    end
    output
  end
end