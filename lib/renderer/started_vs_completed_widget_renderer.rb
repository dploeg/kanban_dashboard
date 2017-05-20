require 'dashing/app'

require_relative '../../lib/renderer/widget_renderer'
require_relative '../../lib/renderer/data/chart_data_builder'
require_relative '../processor/processor_utils'

class StartedVsCompletedWidgetRenderer < WidgetRenderer
  include ChartDataBuilder

  def initialize
    super('started_vs_completed')
  end

  def prepare(work_items, configuration = Hash.new, data = Hash.new)
    @started = data[:started]
    @completed = data[:completed]
  end

  def determine_max_y_axis
    max_started = @started.max_by { |k, v| v }[1]
    max_completed = @completed.max_by { |k, v| v }[1]
    max_y = max_started >= max_completed ? max_started : max_completed
    if max_y > MAX_Y_AXIS_STEPS
      roundup(max_y, MAX_Y_AXIS_STEPS)
    else
      max_y
    end
  end

  private def build_datasets
    datasets = Array.new
    datasets.push(build_started_output)
    datasets.push(build_completed_output)
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

  private def build_labels
    @started.keys
  end

end