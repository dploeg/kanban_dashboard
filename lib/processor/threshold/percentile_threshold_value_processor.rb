require_relative '../processor_utils'

class PercentileThresholdValueProcessor
  include ProcessorUtils

  attr_reader :percentile, :name

  def initialize(percentile = 95)
    @percentile = percentile
    @name = PERCENTILE_THRESHOLD_VALUE_PROCESSOR
  end

  def process(work_items, *thresholds)
    warnings = Array.new
    @percentile_values = populate_percentile_lead_times_from_work_items(sort_into_classes_of_service(work_items), @percentile)

    thresholds.each { |threshold|
      class_of_service = retrieve_class_of_service(threshold)
      actual = @percentile_values[class_of_service]
      check_threshold(actual, threshold, warnings, class_of_service)
    }
    warnings
  end

  private def check_threshold(actual, threshold, warnings, class_of_service)
    if threshold.type == Threshold::LOWER
      if actual < threshold.value #question as to whether to push this down into the threshold itself
        warnings.push(build_warning(actual, threshold, class_of_service))
      end
    else
      if actual > threshold.value
        warnings.push(build_warning(actual, threshold, class_of_service))
      end
    end
  end

  private def retrieve_class_of_service(threshold)
    class_of_service = threshold.class_of_service
    if class_of_service.nil?
      class_of_service = ProcessorUtils::STANDARD_CLASS_OF_SERVICE
    end
    class_of_service
  end

  private def build_warning(actual, threshold, class_of_service)
    ThresholdWarning.new("Lead Time " + @percentile.to_s + " percentile - " + class_of_service,
                         "has exceeded " + threshold.type.downcase + " threshold of " + threshold.value.to_s + " with value of " + actual.to_s)
  end
end