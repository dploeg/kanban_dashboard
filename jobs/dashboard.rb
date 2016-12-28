require_relative '../lib/readers/file_data_reader'
require_relative '../lib/processor/data_processor'
require_relative '../lib/processor/widgets/lead_time_percentile_summary_widget_processor'
require_relative '../lib/processor/widgets/lead_time_distribution_widget_processor'



SCHEDULER.every '10s' do
  reader = FileDataReader.new('assets/work_items/sample_data.json')
  widget_processors = [LeadTimePercentileSummaryWidgetProcessor.new, LeadTimeDistributionWidgetProcessor.new]
  processor = DataProcessor.new(reader, widget_processors)

  processor.process_data
end
