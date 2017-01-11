require_relative '../lib/readers/file_work_item_reader'
require_relative '../lib/readers/file_threshold_reader'
require_relative '../lib/processor/data_processor'
require_relative '../lib/processor/widgets/lead_time_percentile_summary_widget_processor'
require_relative '../lib/processor/widgets/lead_time_distribution_widget_processor'
require_relative '../lib/processor/widgets/control_chart_widget_processor'
require_relative '../lib/processor/widgets/started_vs_finished_widget_processor'
require_relative '../lib/processor/threshold_processor'
require_relative '../lib/processor/threshold/percentile_threshold_value_processor'
require_relative '../lib/processor/widgets/threshold_widget_processor'

SCHEDULER.every '10s' do
  work_item_reader = FileWorkItemReader.new('assets/work_items/sample_data.json')
  threshold_reader = FileThresholdReader.new('assets/work_items/sample_thresholds.json')
  threshold_value_processors = [PercentileThresholdValueProcessor.new]
  threshold_processor = ThresholdProcessor.new(threshold_reader, threshold_value_processors)

  widget_processors = [LeadTimePercentileSummaryWidgetProcessor.new, LeadTimeDistributionWidgetProcessor.new,
                       ControlChartWidgetProcessor.new, StartedVsFinishedWidgetProcessor.new,
                       ThresholdWidgetProcessor.new(threshold_processor)]
  processor = DataProcessor.new(work_item_reader, widget_processors)
  processor.process_data

end
