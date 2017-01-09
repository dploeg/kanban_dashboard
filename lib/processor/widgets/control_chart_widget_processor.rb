require_relative '../processor_utils'

class ControlChartWidgetProcessor
  include ProcessorUtils

  def initialize
    @lead_times_per_CoS = Hash.new
    @background_colors = ["#F7464A", "#F79B46", "#464AF7", "#F7F446", "#F446F7"]
    @hover_background_colors = ["#FF6384", "#FF9063", "#6384FF", "#F9F777", "#F777F9"]
  end


  def process(work_items)
    work_items_per_CoS = sort_into_classes_of_service(work_items)

    work_items_per_CoS.each { |key, array|
      lead_times = Array.new
      ordered_work_items = order_work_items(array)
      ordered_work_items.each { |item|
        lead_times.push(item.lead_time)
      }
      @lead_times_per_CoS[key] = lead_times
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
    @lead_times_per_CoS.each { |key, array|
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
    work_items.sort { |a, b| Date.strptime(a.complete_date, '%d/%m/%Y') <=> Date.strptime(b.complete_date, '%d/%m/%Y') } #refactor date format
  end

  private def build_data(data_items, counter)
    data = Array.new

    data_items.each {
        |lead_time|
      data.push({:x => counter, :y => lead_time, :r => 5})
      counter += 1
    }
    data
  end

end