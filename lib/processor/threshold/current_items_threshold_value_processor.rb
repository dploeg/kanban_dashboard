require_relative '../../../lib/model/work_item'
require_relative '../../../lib/model/threshold_warning'
require_relative '../processor_utils'

class CurrentItemsThresholdValueProcessor
  include ProcessorUtils

  attr_reader :name

  def initialize
    @name = ProcessorUtils::CURRENT_ITEMS_THRESHOLD_VALUE_PROCESSOR
  end

  def process(work_items, *thresholds)
    warnings = Array.new

    thresholds.each { |threshold|
      count = count_warnings_for_threshold(threshold, work_items)
      if count > 0
        warnings.push(build_warning(count, threshold))
      end
    }
    warnings
  end

  def count_warnings_for_threshold(threshold, work_items)
    count = 0
    if threshold.class_of_service.nil?
      work_items.each { |work_item|
        if work_item.complete_date.nil? && threshold_value_exceeded(threshold, work_item)
          count +=1
        end
      }
    else
      class_of_service_items = sort_into_classes_of_service(work_items)
      class_of_service_items[threshold.class_of_service].each { |work_item|
        if work_item.complete_date.nil? && threshold_value_exceeded(threshold, work_item)
          count +=1
        end
      }
    end
    count
  end

  def threshold_value_exceeded(threshold, work_item)
    Date.strptime(work_item.start_date, WorkItem::DATE_FORMAT) < Date.today - threshold.value
  end

  private def build_warning(count, threshold)
    if threshold.class_of_service.nil?
      if count > 1
        ThresholdWarning.new("In Progress time (incomplete items)",
                             "has exceeded the %s threshold of %d days for %d items" % [threshold.type.downcase, threshold.value, count])
      else
        ThresholdWarning.new("In Progress time (incomplete items)",
                             "has exceeded the %s threshold of %d days for 1 item" % [threshold.type.downcase, threshold.value])
      end
    else
      if count > 1
        ThresholdWarning.new("In Progress time (incomplete items) - %s" % [threshold.class_of_service],
                             "has exceeded the %s threshold of %d days for %d items" % [threshold.type.downcase, threshold.value, count])
      else
        ThresholdWarning.new("In Progress time (incomplete items) - %s" % [threshold.class_of_service],
                             "has exceeded the %s threshold of %d days for 1 item" % [threshold.type.downcase, threshold.value])
      end
    end
  end

end