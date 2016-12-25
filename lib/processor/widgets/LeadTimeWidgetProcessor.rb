require 'descriptive_statistics'
require 'dashing/app'

class LeadTimeWidgetProcessor

  def initialize(percentile = 95)
    @percentile = percentile
    @percentile_values = Hash.new
  end

  STANDARD_CLASS_OF_SERVICE = "Standard"

  def process(work_items)
    classes_of_service_items = sort_into_classes_of_service(work_items)
    populate_percentile_lead_times_from_work_items(classes_of_service_items)
  end

  def output
    send_event('lead_times', { items: convert_to_output })
  end

  def lead_time_95th_percentile(class_of_service = STANDARD_CLASS_OF_SERVICE)
    @percentile_values[class_of_service]
  end

  def convert_to_output
    output = Array.new
    @percentile_values.keys.each { |class_of_service|
      output.push({"label" => class_of_service, "value" => @percentile_values[class_of_service]})
    }
    output
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