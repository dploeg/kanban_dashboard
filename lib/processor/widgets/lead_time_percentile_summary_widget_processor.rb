require 'descriptive_statistics'
require 'dashing/app'

require_relative '../processor_utils'

class LeadTimePercentileSummaryWidgetProcessor
include ProcessorUtils


  def initialize(percentile = 95)
    @percentile = percentile
    @percentile_values = Hash.new
  end

  def process(work_items)
    classes_of_service_items = sort_into_classes_of_service(work_items)
    populate_percentile_lead_times_from_work_items(classes_of_service_items)
  end

  def output
    send_event('lead_times', build_output_hash)
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

  private def populate_percentile_lead_times_from_work_items(classes_of_service_items)
    classes_of_service_items.keys.each {
        |class_of_service|

      lead_times = Array.new
      classes_of_service_items[class_of_service].each {
          |item|
        lead_times.push(item.lead_time)
      }

      @percentile_values[class_of_service] = lead_times.percentile(@percentile).to_i
    }
  end

end