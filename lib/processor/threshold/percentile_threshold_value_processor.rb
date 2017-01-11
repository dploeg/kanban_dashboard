require_relative '../processor_utils'

class PercentileThresholdValueProcessor
  include ProcessorUtils

  def initialize
    @percentile = 95
  end

  def process(work_items, *thresholds)
    warnings = Array.new
    @percentile_values = populate_percentile_lead_times_from_work_items(sort_into_classes_of_service(work_items), @percentile)

    thresholds.each { |threshold|
      class_of_service = threshold.class_of_service
      if class_of_service.nil?
        class_of_service = ProcessorUtils::STANDARD_CLASS_OF_SERVICE
      end
      actual = @percentile_values[class_of_service]
      if(threshold.type == Threshold::LOWER)
        if actual < threshold.value #question as to whether to push this down into the threshold itself
          warnings.push(build_warning(actual, threshold))
        end
      else
        if actual > threshold.value
          warnings.push(build_warning(actual, threshold))
        end
      end
    }
    warnings
  end

  private def build_warning(actual, threshold)
    ThresholdWarning.new("Lead Time " + @percentile.to_s + " percentile",
                         "has exceeded " + threshold.type.downcase + " threshold of " + threshold.value.to_s + " with value of " + actual.to_s)
  end
end