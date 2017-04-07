require 'dashing/app'
require_relative '../../../lib/processor/widgets/widget_processor'
require_relative '../../../lib/processor/widgets/data/chart_data_builder'

class LeadTimeDistributionWidgetProcessor < WidgetProcessor
  include ChartDataBuilder

  def initialize(number_of_x_axis_labels = 20)
    super('lead_time_distribution')
    @num_x_axis_labels = number_of_x_axis_labels
  end

  def process(work_items, configuration = Hash.new, data = Hash.new)
    @lead_times = Array.new
    work_items.each { |item|
      unless item.lead_time.nil?
        @lead_times.push(item.lead_time)
      end
    }
  end

  private def build_options
    {
        scales: {
            xAxes: [{
                        scaleLabel: {
                            display: true,
                            labelString: "Lead Time Values (calendar days from start to complete)"
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
                            labelString: "Item Count"
                        }

                    }]
        }
    }
  end

  def determine_max_y_axis
    if add_lead_time_data.max < MAX_Y_AXIS_STEPS
      return add_lead_time_data.max
    else
      return roundup(add_lead_time_data.max, MAX_Y_AXIS_STEPS)
    end
  end

  def build_datasets
    datasets = Array.new
    planned = Hash.new
    planned[:label] = 'Planned'
    planned[:data] = add_lead_time_data
    add_formatting_to_dataset(planned, 'rgba(255, 206, 86, 0.2)', 'rgba(255, 206, 86, 1)', @num_x_axis_labels)
    datasets.push(planned)
  end

  def add_lead_time_data
    lead_time_hash = Hash.new
    increment = ((@lead_times.max - @lead_times.min) / @num_x_axis_labels.to_f).ceil
    for i in 0..@num_x_axis_labels - 1
      lead_time_hash[(@lead_times.min + i * increment)] = 0
    end


    last_min = -1
    @lead_times.each { |lead_time|
      lead_time_hash.keys.each { |key|
        last_min = key
        break if key.to_i>=lead_time
      }
      lead_time_hash[last_min] = lead_time_hash[last_min] +1
    }

    lead_time_hash.values
  end

  def build_labels()
    labels = Array.new
    increment = ((@lead_times.max - @lead_times.min) / @num_x_axis_labels.to_f).ceil
    for i in 0..@num_x_axis_labels - 1
      labels.push(@lead_times.min + i * increment)
    end
    labels
  end

end