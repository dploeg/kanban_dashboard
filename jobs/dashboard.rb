require_relative '../lib/readers/file_data_reader'
require_relative '../lib/processor/data_processor'
require_relative '../lib/processor/widgets/lead_time_percentile_summary_widget_processor'
require_relative '../lib/processor/widgets/lead_time_distribution_widget_processor'
require_relative '../lib/processor/widgets/control_chart_widget_processor'



SCHEDULER.every '10s' do
  reader = FileDataReader.new('assets/work_items/sample_data.json')
  widget_processors = [LeadTimePercentileSummaryWidgetProcessor.new, LeadTimeDistributionWidgetProcessor.new, ControlChartWidgetProcessor.new]
  processor = DataProcessor.new(reader, widget_processors)

  processor.process_data

=begin
  data = [
    {
      label: 'First dataset',
      data: [
        { x: rand(30), y: rand(30), r: rand(5..15) },
        { x: rand(30), y: rand(30), r: rand(5..15) },
        { x: rand(30), y: rand(30), r: rand(5..15) },
        { x: rand(30), y: rand(30), r: rand(5..15) },
        { x: rand(30), y: rand(30), r: rand(5..15) },
      ],
      backgroundColor: '#F7464A',
      hoverBackgroundColor: '#FF6384',
    },
    {
      label: 'Second dataset',
      data: [
        { x: rand(30), y: rand(30), r: rand(5..15) },
        { x: rand(30), y: rand(30), r: rand(5..15) },
        { x: rand(30), y: rand(30), r: rand(5..15) },
        { x: rand(30), y: rand(30), r: rand(5..15) },
        { x: rand(30), y: rand(30), r: rand(5..15) },
      ],
      backgroundColor: '#46BFBD',
      hoverBackgroundColor: '#36A2EB',
    },
  ]
  send_event('control_chart', { datasets: data })
=end

end
