require 'dashing/app'

require_relative '../../../lib/processor/widgets/widget_processor'
require_relative '../../../lib/processor/widgets/data/chart_data_builder'
require_relative '../processor_utils'

class ControlChartWidgetProcessor < WidgetProcessor
  include ProcessorUtils, ChartDataBuilder

  MAX_X_AXIS_STEPS = 20
  MAX_Y_AXIS_STEPS = 20

  def initialize
    super('control_chart')
    @work_items_per_CoS = Hash.new
    @background_colors = ["#F7464A", "#F79B46", "#464AF7", "#F7F446", "#F446F7"]
    @hover_background_colors = ["#FF6384", "#FF9063", "#6384FF", "#F9F777", "#F777F9"]
  end


  def process(work_items, configuration = Hash.new)
    filtered_items = filter_incomplete_items(work_items)
    ordered_work_items = order_work_items_by_completed(filtered_items)
    decorate_with_x_position(ordered_work_items)
    @work_items_per_CoS = sort_into_classes_of_service(ordered_work_items)

  end

  def build_output_hash
    output = Hash.new

    output[:datasets] = build_datasets
    output[:options] = build_options

    output
  end

  private def decorate_with_x_position(work_items)
    position = 1
    work_items.each { |item|
      item.additional_values[:x_position] = position
      position+=1
    }
  end

  private def build_datasets
    datasets = Array.new
    colour_counter = 0
    x_counter = 1
    @work_items_per_CoS.each { |key, array|
      datasets.push({:label => key, :data => build_data(array, x_counter), :backgroundColor => @background_colors[colour_counter], :hoverBackgroundColor => @hover_background_colors[colour_counter]})
      colour_counter+=1
      x_counter += array.size
    }

    #add line chart details here
=begin
    datasets.push({
        :type => 'line',
        :label => '95th Percentile',
        :data => Array.new(x_counter) { 32 },
        :backgroundColor => [ '#0f6e02' ] * x_counter,
        :borderColor => [ '#0f6e02' ] * x_counter,
        :borderWidth => 1,
      })
=end

    datasets.push({
                      :type => 'line',
                      :label => '95th Percentile',
                      :data => [{:x => 0, :y => 32}, {:x => x_counter, :y => 32}],
                      # :backgroundColor => [ '#303030' ],
                      :borderColor => ['#0f6e02'],
                      :borderWidth => 5,
                      :fill => false,
                      :pointRadius => 0,
                  },
                  {
                      :type => 'line',
                      :label => '95th Percentile',
                      :data => [{:x => 0, :y => 25}, {:x => x_counter, :y => 25}],
                      # :backgroundColor => [ '#303030' ],
                      :borderColor => ['#F79B46'],
                      :borderWidth => 5,
                      :fill => false,
                      :pointRadius => 0,
                  }
    )
    puts 'data for control chart' + datasets.to_s
    datasets
  end

  private def build_options
    {
        scales: {
            xAxes: [{
                        ticks: {
                            beginAtZero: true,
                            stepSize: determine_x_axis_step_size,
                            min: 0,
                            max: determine_max_x_axis
                        },
                        scaleLabel: {
                            display: true,
                            labelString: "Work Item"
                        }

                    }],
            yAxes: [{
                        ticks: {
                            beginAtZero: true,
                            stepSize: determine_y_axis_step_size,
                            min: 0,
                            max: determine_max_y_axis
                        },
                        scaleLabel: {
                            display: true,
                            labelString: "Lead Time"
                        }
                    }]
        }
    }
  end

  private def determine_max_x_axis
    max =0
    @work_items_per_CoS.each { |key, value|
      max += value.size
    }
    if max > MAX_X_AXIS_STEPS
      max = roundup(max, MAX_X_AXIS_STEPS)
    end
    max

  end

  private def determine_x_axis_step_size
    rounded_max_x = determine_max_x_axis

    rounded_max_x / MAX_X_AXIS_STEPS > 1 ? rounded_max_x / MAX_X_AXIS_STEPS : 1
  end

  private def determine_max_y_axis
    max =1
    @work_items_per_CoS.each { |key, value|
      value.each { |work_item|
        if work_item.lead_time > max
          max = work_item.lead_time
        end
      }
    }
    if max > MAX_Y_AXIS_STEPS
      max = roundup(max, MAX_Y_AXIS_STEPS)
    end
    max
  end


  private def determine_y_axis_step_size
    rounded_max_y = determine_max_y_axis

    rounded_max_y / MAX_Y_AXIS_STEPS > 1 ? rounded_max_y / MAX_Y_AXIS_STEPS : 1
  end

  private def build_data(data_items, counter)
    data = Array.new

    data_items.each {
        |item|
      data.push({:x => item.additional_values[:x_position], :y => item.lead_time, :r => 5})
      counter += 1
    }
    data
  end

end