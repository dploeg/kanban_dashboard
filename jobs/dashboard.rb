require_relative '../lib/readers/work_item/file_work_item_reader'
require_relative '../lib/readers/threshold/file_threshold_reader'
require_relative '../lib/readers/file_config_reader'
require_relative '../lib/processor/dashboard_processor'
require_relative '../lib/renderer/lead_time_percentile_summary_renderer'
require_relative '../lib/renderer/lead_time_distribution_renderer'
require_relative '../lib/renderer/control_chart_renderer'
require_relative '../lib/renderer/started_vs_completed_renderer'
require_relative '../lib/renderer/net_flow_renderer'
require_relative '../lib/processor/threshold_processor'
require_relative '../lib/processor/threshold/percentile_threshold_value_processor'
require_relative '../lib/processor/threshold/current_items_threshold_value_processor'
require_relative '../lib/renderer/threshold_renderer'
require_relative '../lib/renderer/cumulative_flow_renderer'
require_relative '../lib/renderer/throughput_renderer'
require_relative '../lib/renderer/forecast_renderer'
require_relative '../lib/renderer/forecast_vs_target_renderer'
require_relative '../lib/processor/data/started_vs_completed_data_processor'
require_relative '../lib/processor/data/forecast_data_processor'

SCHEDULER.every '10s' do
  work_item_reader = FileWorkItemReader.new('assets/dashboard_data/work_item_data.json')
  threshold_reader = FileThresholdReader.new('assets/dashboard_data/thresholds.json')
  config_reader = FileConfigReader.new('assets/dashboard_data/dashboard_config.yaml')
  threshold_value_processors = [PercentileThresholdValueProcessor.new, CurrentItemsThresholdValueProcessor.new]
  threshold_processor = ThresholdProcessor.new(threshold_reader, threshold_value_processors)

  data_processors = [StartedVsCompletedDataProcessor.new, ForecastDataProcessor.new]

  widget_processors = [LeadTimePercentileSummaryRenderer.new, LeadTimeDistributionRenderer.new,
                       ControlChartRenderer.new, StartedVsCompletedRenderer.new,
                       NetFlowRenderer.new, CumulativeFlowRenderer.new,
                       ThroughputRenderer.new, ForecastRenderer.new,
                       ForecastVsTargetRenderer.new,
                       ThresholdRenderer.new(threshold_processor)]

  processor = DashboardProcessor.new(work_item_reader, config_reader, widget_processors, data_processors)
  processor.process_dashboards

end
