require 'dashing/app'

require_relative '../processor_utils'

class StartedVsFinishedWidgetProcessor < StartedVsFinishedDataProcessor
  include ProcessorUtils

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
    add_formatting_to_dataset(started, 'rgba(255, 99, 132, 0.2)', 'rgba(255, 99, 132, 1)')
    started
  end

  private def build_completed_output
    completed = Hash.new
    completed['label'] = 'Completed'
    completed['data'] = @completed.values
    add_formatting_to_dataset(completed, 'rgba(92, 255, 127, 0.2)', 'rgba(92, 255, 127, 1)')
    completed
  end

  private def add_formatting_to_dataset(data, background, border)
    background_colors = Array.new
    border_colors = Array.new
    (0..@started.length-1).each {
      background_colors.push(background)
      border_colors.push(border)
    }
    data['backgroundColor'] = background_colors
    data['borderColor'] = border_colors
    data['borderWidth'] = 1
  end

end