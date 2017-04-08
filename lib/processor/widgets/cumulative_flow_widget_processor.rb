require 'dashing/app'

require_relative '../../../lib/processor/widgets/widget_processor'
require_relative '../../../lib/processor/widgets/data/chart_data_builder'

class CumulativeFlowWidgetProcessor < WidgetProcessor
  include ChartDataBuilder

  def initialize
    super('cumulative_flow')
  end

  def process(work_items, configuration = Hash.new, data = Hash.new)
    @started = data[:started]
    @completed = data[:completed]
  end

  private def build_datasets
    datasets = Array.new

    started = build_started_output
    completed = build_completed_output
    datasets.push(completed)
    datasets.push(started)
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
    started[:label] = 'Started'
    started[:data] = accumulate_values(@started.values)
    add_formatting_to_dataset(started, 'rgba(227, 175, 116, 1)', 'rgba(190, 120, 39, 1)', @started.length)
    started[:lineTension] = 0
    started
  end

  private def build_completed_output
    completed = Hash.new
    completed[:label] = 'Completed'
    completed[:data] = accumulate_values(@completed.values)
    add_formatting_to_dataset(completed, 'rgba(161, 192, 229, 1)', 'rgba(44, 96, 160, 1)', @started.length)
    completed[:lineTension] = 0
    completed
  end

  private def build_labels
    @started.keys
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