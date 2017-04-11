require_relative '../../../lib/processor/widgets/widget_renderer'
require_relative '../../../lib/processor/widgets/data/chart_data_builder'

require 'dashing/app'

class NetFlowWidgetRenderer < WidgetRenderer
  include ChartDataBuilder

  def initialize
    super('net_flow')
  end

  def prepare(work_items, configuration = Hash.new, data = Hash.new)
    @started = data[:started]
    @completed = data[:completed]
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
    flow[:label] = 'Net Flow'
    flow[:data] = flow_data
    flow[:backgroundColor] = background_colors
    flow[:borderColor] = border_colors
    flow[:borderWidth] = 1
    flow
  end

  private def build_options

  end

  private def build_labels
    @started.keys
  end
end