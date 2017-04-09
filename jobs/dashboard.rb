require_relative '../lib/readers/work_item/file_work_item_reader'
require_relative '../lib/readers/threshold/file_threshold_reader'
require_relative '../lib/readers/file_config_reader'
require_relative '../lib/processor/dashboard_processor'
require_relative '../lib/processor/widgets/lead_time_percentile_summary_widget_processor'
require_relative '../lib/processor/widgets/lead_time_distribution_widget_processor'
require_relative '../lib/processor/widgets/control_chart_widget_processor'
require_relative '../lib/processor/widgets/started_vs_completed_widget_processor'
require_relative '../lib/processor/widgets/net_flow_widget_processor'
require_relative '../lib/processor/threshold_processor'
require_relative '../lib/processor/threshold/percentile_threshold_value_processor'
require_relative '../lib/processor/threshold/current_items_threshold_value_processor'
require_relative '../lib/processor/widgets/threshold_widget_processor'
require_relative '../lib/processor/widgets/cumulative_flow_widget_processor'
require_relative '../lib/processor/widgets/throughput_widget_processor'
require_relative '../lib/processor/widgets/forecast_widget_processor'
require_relative '../lib/processor/widgets/forecast_vs_target_widget_renderer'
require_relative '../lib/processor/data/started_vs_completed_data_processor'
require_relative '../lib/processor/data/forecast_data_processor'

SCHEDULER.every '10s' do
  work_item_reader = FileWorkItemReader.new('assets/dashboard_data/work_item_data.json')
  threshold_reader = FileThresholdReader.new('assets/dashboard_data/thresholds.json')
  config_reader = FileConfigReader.new('assets/dashboard_data/dashboard_config.yaml')
  threshold_value_processors = [PercentileThresholdValueProcessor.new, CurrentItemsThresholdValueProcessor.new]
  threshold_processor = ThresholdProcessor.new(threshold_reader, threshold_value_processors)

  data_processors = [StartedVsCompletedDataProcessor.new, ForecastDataProcessor.new]

  widget_processors = [LeadTimePercentileSummaryWidgetProcessor.new, LeadTimeDistributionWidgetProcessor.new,
                       ControlChartWidgetProcessor.new, StartedVsCompletedWidgetProcessor.new,
                       NetFlowWidgetProcessor.new, CumulativeFlowWidgetProcessor.new,
                       ThroughputWidgetProcessor.new, ForecastWidgetProcessor.new,
                       ForecastVsTargetWidgetRenderer.new,
                       ThresholdWidgetProcessor.new(threshold_processor)]

  processor = DashboardProcessor.new(work_item_reader, config_reader, widget_processors, data_processors)
  processor.process_dashboards

end
