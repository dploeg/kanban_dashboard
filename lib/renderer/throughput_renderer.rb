require 'dashing/app'
require_relative '../../lib/renderer/base_renderer'
require_relative '../../lib/renderer/data/chart_data_builder'

class ThroughputRenderer < BaseRenderer
  include ChartDataBuilder

  def initialize(number_of_x_axis_labels = 20)
    super('throughput')
    @number_of_x_axis_labels = number_of_x_axis_labels
  end

  def prepare(work_items, configuration = Hash.new, data = Hash.new)
    @throughput = Hash.new
    data[:completed].each_value { |number_completed|
      if @throughput[number_completed].nil?
        @throughput[number_completed] = 1
      else
        @throughput[number_completed] = @throughput[number_completed] + 1
      end
    }
  end

  private def build_options
      {
          scales: {
              xAxes: [{
                          scaleLabel: {
                              display: true,
                              labelString: "Throughput value (number of items completed in a calendar week)"
                          }

                      }],
              yAxes: [{
                          stacked: false,
                          ticks: {
                              min: 0,
                              stepSize: determine_y_axis_step_size,
                              max: determine_max_y_axis
                          },
                          scaleLabel: {
                              display: true,
                              labelString: "Count of weeks with value"
                          }

                      }]
          }
      }
  end

  private def build_labels
    labels = Array.new

    increment = (x_axis_base_range / @number_of_x_axis_labels.to_f).ceil
    for i in 0..@number_of_x_axis_labels - 1
      labels.push(@throughput.keys.min + i * increment)
    end
    labels
  end

  private def x_axis_base_range
    if @throughput.keys.max - @throughput.keys.min == 0
      @number_of_x_axis_labels
    else
      @throughput.keys.max - @throughput.keys.min
    end
  end

  private def build_datasets
    datasets = Array.new
    tp_frequency = Hash.new
    tp_frequency[:label] = 'Throughput Frequency'
    tp_frequency[:data] = add_lead_time_data
    add_formatting_to_dataset(tp_frequency, 'rgba(255, 206, 86, 0.2)', 'rgba(255, 206, 86, 1)', @number_of_x_axis_labels)
    datasets.push(tp_frequency)
  end

  private def add_lead_time_data
    throughput_hash = Hash.new
    increment = (x_axis_base_range / @number_of_x_axis_labels.to_f).ceil
    for i in 0..@number_of_x_axis_labels - 1
      key = (@throughput.keys.min + i * increment)
      if @throughput[key].nil?
        throughput_hash[key] = 0
      else
        throughput_hash[key] = @throughput[key]
      end
    end

    throughput_hash.values
  end

  private def determine_max_y_axis
    10
  end
end