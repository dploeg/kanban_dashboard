require 'dashing/app'

require_relative '../../../lib/processor/widgets/widget_processor'
require_relative '../../../lib/processor/widgets/data/started_vs_finished_data_processor'
require_relative '../../../lib/processor/widgets/data/chart_data_builder'

class CumulativeFlowWidgetProcessor < WidgetProcessor
  include StartedVsFinishedDataProcessor, ChartDataBuilder

  def initialize
    super('cumulative_flow')
  end

  private def build_datasets
    datasets = Array.new

    started = build_started_output
    completed = build_completed_output
    datasets.push(started)
    datasets.push(completed)
  end

  private def build_options
    {
        scales: {
            yAxes: [{
                        stacked: false
                    }]
        }
    }
  end

  private def build_started_output
    started = Hash.new
    started['label'] = 'Started'
    started['data'] = accumulate_values(@started.values)
    add_formatting_to_dataset(started, 'rgba(255, 99, 132, 0.2)', 'rgba(255, 99, 132, 1)', @started.length)
    started['lineTension'] = 0
    started
  end

  private def build_completed_output
    completed = Hash.new
    completed['label'] = 'Completed'
    completed['data'] = accumulate_values(@completed.values)
    add_formatting_to_dataset(completed, 'rgba(0, 143, 31, 1)', 'rgba(92, 255, 127, 1)', @started.length)
    completed['lineTension'] = 0
    completed
  end

  def accumulate_values(values)
    accumulated = Array.new

    running_total = 0
    values.each { |value|
      running_total+=value
      accumulated.push(running_total)
    }

    accumulated
  end

end