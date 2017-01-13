require 'dashing/app'

require_relative '../../../lib/processor/widgets/widget_processor'
require_relative '../../../lib/processor/widgets/data/started_vs_completed_data_processor'
require_relative '../../../lib/processor/widgets/data/chart_data_builder'
require_relative '../processor_utils'

class StartedVsCompletedWidgetProcessor < WidgetProcessor
  include StartedVsCompletedDataProcessor, ChartDataBuilder

  def initialize
    super('started_vs_finished')
  end

  def determine_max_y_axis
    max_started = @started.max_by { |k, v| v }[1]
    max_completed = @completed.max_by { |k, v| v }[1]
    max_y = max_started >= max_completed ? max_started : max_completed
    if max_y > 10
      roundup(max_y)
    else
      max_y
    end
  end

  private def build_datasets
    datasets = Array.new

    started = build_started_output
    completed = build_completed_output
    datasets.push(started)
    datasets.push(completed)
    datasets
  end

  private def build_started_output
    started = Hash.new
    started[:label] = 'Started'
    started[:data] = @started.values
    add_formatting_to_dataset(started, 'rgba(227, 175, 116, 1)', 'rgba(190, 120, 39, 1)', @started.length)
    started
  end

  private def build_completed_output
    completed = Hash.new
    completed[:label] = 'Completed'
    completed[:data] = @completed.values
    add_formatting_to_dataset(completed, 'rgba(161, 192, 229, 1)', 'rgba(44, 96, 160, 1)', @started.length)
    completed
  end

end