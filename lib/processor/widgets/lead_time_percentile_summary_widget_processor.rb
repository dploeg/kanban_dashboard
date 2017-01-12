require 'descriptive_statistics'
require 'dashing/app'


require_relative '../../../lib/processor/widgets/widget_processor'
require_relative '../processor_utils'

class LeadTimePercentileSummaryWidgetProcessor < WidgetProcessor
  include ProcessorUtils


  def initialize(percentile = 95)
    super('lead_times')
    @percentile = percentile
    @percentile_values = Hash.new
  end

  def process(work_items)
    classes_of_service_items = sort_into_classes_of_service(work_items)
    @percentile_values = populate_percentile_lead_times_from_work_items(classes_of_service_items, @percentile)
  end

  def lead_time_95th_percentile(class_of_service = STANDARD_CLASS_OF_SERVICE)
    @percentile_values[class_of_service]
  end

  def build_output_hash
    output_map = Hash.new
    labels_and_values = Array.new
    @percentile_values.keys.each { |class_of_service|
      labels_and_values.push({"label" => class_of_service, "value" => @percentile_values[class_of_service]})
    }
    output_map["items"] = labels_and_values
    output_map
  end


end