require_relative '../../../lib/processor/widgets/widget_processor'
require_relative '../../../lib/processor/data/started_vs_finished_data_processor'

require 'dashing/app'

class NetFlowWidgetProcessor < WidgetProcessor
  include StartedVsFinishedDataProcessor

  def initialize
    super('net_flow')
  end

  private def build_datasets
    datasets = Array.new

    flow = populate_flow_data
    datasets.push(flow)
    datasets
  end

  private def populate_flow_data
    flow_data = Array.new
    background_colors = Array.new
    border_colors = Array.new

    @started.each { |key, started|
      completed = @completed[key]
      net_flow = completed - started
      flow_data.push(net_flow)
      if net_flow < 0
        background_colors.push('rgba(255, 99, 132, 0.2)')
        border_colors.push('rgba(255, 99, 132, 1)')
      else
        background_colors.push('rgba(92, 255, 127, 0.2)')
        border_colors.push('rgba(92, 255, 127, 1)')
      end
    }
    build_flow_hash(background_colors, border_colors, flow_data)
  end

  def build_flow_hash(background_colors, border_colors, flow_data)
    flow = Hash.new
    flow['label'] = 'Net Flow'
    flow['data'] = flow_data
    flow['backgroundColor'] = background_colors
    flow['borderColor'] = border_colors
    flow['borderWidth'] = 1
    flow
  end

  private def build_options

  end
end