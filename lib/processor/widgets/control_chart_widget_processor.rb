require_relative '../processor_utils'

class ControlChartWidgetProcessor
  include ProcessorUtils

  def initialize
    @work_items_per_CoS = Hash.new
    @background_colors = ["#F7464A", "#F79B46", "#464AF7", "#F7F446", "#F446F7"]
    @hover_background_colors = ["#FF6384", "#FF9063", "#6384FF", "#F9F777", "#F777F9"]
  end


  def process(work_items)
    ordered_work_items = order_work_items(work_items)
    decorate_with_x_position(ordered_work_items)
    @work_items_per_CoS = sort_into_classes_of_service(ordered_work_items)

  end

  def decorate_with_x_position(work_items)
    position = 1
    work_items.each {|item|
      item.additional_values[:x_position] = position
      position+=1
    }
  end

  def output
    send_event('control_chart', build_output_hash)
  end

  def build_output_hash
    output = Hash.new

    output['datasets'] = build_datasets
    output['options'] = build_options

    output
  end

  def build_datasets
    datasets = Array.new
    colour_counter = 0
    x_counter = 1
    @work_items_per_CoS.each { |key, array|
      datasets.push({:label => key, :data => build_data(array, x_counter), :backgroundColor => @background_colors[colour_counter], :hoverBackgroundColor => @hover_background_colors[colour_counter]})
      colour_counter+=1
      x_counter += array.size
    }
    datasets
  end

  def build_options
    {
        scales: {
            xAxes: [{
                        ticks: {
                            beginAtZero: true,
                            stepSize: 1.0
                        }
                    }],
            yAxes: [{
                        ticks: {
                            beginAtZero: true,
                            fixedStepSize: 1.0
                        }
                    }]
        }
    }
  end

  private def order_work_items(work_items)
    work_items.sort { |a, b| Date.strptime(a.complete_date, WorkItem::DATE_FORMAT) <=> Date.strptime(b.complete_date, WorkItem::DATE_FORMAT) }
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