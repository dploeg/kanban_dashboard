require 'descriptive_statistics'

module ProcessorUtils
  STANDARD_CLASS_OF_SERVICE = "Standard"
  PERCENTILE_THRESHOLD_VALUE_PROCESSOR = "percentile"

  def sort_into_classes_of_service(work_items)
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

  def order_work_items_by_completed(work_items)
    work_items.sort { |a, b| Date.strptime(a.complete_date, WorkItem::DATE_FORMAT) <=> Date.strptime(b.complete_date, WorkItem::DATE_FORMAT) }
  end

  def filter_incomplete_items(work_items)
    filtered = Array.new
    work_items.each {|item|
      unless item.complete_date.nil?
        filtered.push(item)
      end
    }
    filtered
  end

  def order_work_items_by_started(work_items)
    work_items.sort { |a, b| Date.strptime(a.start_date, WorkItem::DATE_FORMAT) <=> Date.strptime(b.start_date, WorkItem::DATE_FORMAT) }
  end

  def populate_percentile_lead_times_from_work_items(classes_of_service_items, percentile)
    percentile_values = Hash.new
    classes_of_service_items.keys.each {
        |class_of_service|

      lead_times = Array.new
      classes_of_service_items[class_of_service].each {
          |item|
        unless item.complete_date.nil?
          lead_times.push(item.lead_time)
        end
      }

      percentile_values[class_of_service] = lead_times.percentile(percentile).to_i
    }
    percentile_values
  end


end