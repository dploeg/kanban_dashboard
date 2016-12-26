require_relative '../lib/readers/file_data_reader'
require_relative '../lib/processor/data_processor'
require_relative '../lib/processor/widgets/LeadTimePercentileSummaryWidgetProcessor'



SCHEDULER.every '10s' do
  reader = FileDataReader.new('assets/work_items/sample_data.json')
  widget_processors = [LeadTimePercentileSummaryWidgetProcessor.new]
  processor = DataProcessor.new(reader, widget_processors)

  processor.process_data
end
