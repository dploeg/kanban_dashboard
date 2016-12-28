require 'descriptive_statistics'
require 'dashing/app'

class LeadTimePercentileSummaryWidgetProcessor

  STANDARD_CLASS_OF_SERVICE = "Standard"

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

  private def sort_into_classes_of_service(work_items)
    classes_of_service = Hash.new
    work_items.each {
        |item|
      if item.class_of_service.nil?
        unless classes_of_service.has_key?(STANDARD_CLASS_OF_SERVICE)
          classes_of_service[STANDARD_CLASS_OF_SERVICE] = Array.new
        end
        classes_of_service[STANDARD_CLASS_OF_SERVICE].push(item)
      else
        unless classes_of_service.include?(item.class_of_service)
          classes_of_service[item.class_of_service] = Array.new
        end
        classes_of_service[item.class_of_service].push(item)
      end
    }
    classes_of_service
  end

end