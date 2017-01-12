require 'dashing/app'

require_relative '../../../lib/processor/widgets/widget_processor'
require_relative '../../../lib/processor/widgets/data/started_vs_finished_data_processor'
require_relative '../../../lib/processor/widgets/data/chart_data_builder'
require_relative '../processor_utils'

class StartedVsFinishedWidgetProcessor < WidgetProcessor
  include StartedVsFinishedDataProcessor, ChartDataBuilder

  def initialize
    super('started_vs_finished')
  end

  private def build_options
    options = Hash.new
    options['scales'] = {'yAxes'=> [{'stacked' => false, 'ticks' =>{'min' =>0, 'stepSize' => 1}}]}
    options
  end

  private def build_datasets
    datasets = Array.new

    started = build_started_output
    completed = build_completed_output
    datasets.push(started)
    datasets.push(completed)
  end

  private def build_started_output
    started = Hash.new
    started['label'] = 'Started'
    started['data'] = @started.values
    add_formatting_to_dataset(started, 'rgba(255, 99, 132, 0.2)', 'rgba(255, 99, 132, 1)', @started.length)
    started
  end

  private def build_completed_output
    completed = Hash.new
    completed['label'] = 'Completed'
    completed['data'] = @completed.values
    add_formatting_to_dataset(completed, 'rgba(92, 255, 127, 0.2)', 'rgba(92, 255, 127, 1)', @started.length)
    completed
  end

end