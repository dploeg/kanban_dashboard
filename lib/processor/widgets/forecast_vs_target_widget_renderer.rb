require 'dashing/app'
require_relative 'widget_processor'
require_relative '../../../lib/model/work_item'

class ForecastVsTargetWidgetRenderer < WidgetProcessor

  def initialize
    super('forecast_vs_target')
  end

  def process(work_items, configuration = Hash.new, data = Hash.new)
    @forecasts = data[:forecasts]
    @target_date = configuration[:forecast_config][:target_complete_date]
  end

  def build_output_hash
    output = Hash.new

    output[:datasets] = build_datasets
    output[:options] = build_options
    output
  end

  private def build_datasets
    datasets = Array.new

    datasets.push({:label => "Are you nuts?",
                   :data => [{:x => Date.strptime(@forecasts["percentile20".to_sym].complete_date, WorkItem::DATE_FORMAT), :y => 20, :r => 5},
                             {:x => Date.strptime(@forecasts["percentile35".to_sym].complete_date, WorkItem::DATE_FORMAT), :y => 35, :r => 5}],
                   :backgroundColor => "#F7464A",
                   :hoverBackgroundColor => "#F7464A"})
    datasets.push({:label => "Caution",
                   :data => [{:x => Date.strptime(@forecasts["percentile50".to_sym].complete_date, WorkItem::DATE_FORMAT), :y => 50, :r => 5},
                             {:x => Date.strptime(@forecasts["percentile65".to_sym].complete_date, WorkItem::DATE_FORMAT), :y => 65, :r => 5},
                             {:x => Date.strptime(@forecasts["percentile75".to_sym].complete_date, WorkItem::DATE_FORMAT), :y => 75, :r => 5}],
                   :backgroundColor => "#F7F446",
                   :hoverBackgroundColor => "#F7F446"})
    datasets.push({:label => "Safe zone",
                   :data => [{:x => Date.strptime(@forecasts["percentile85".to_sym].complete_date, WorkItem::DATE_FORMAT), :y => 85, :r => 5},
                             {:x => Date.strptime(@forecasts["percentile95".to_sym].complete_date, WorkItem::DATE_FORMAT), :y => 95, :r => 5},
                             {:x => Date.strptime(@forecasts["percentile100".to_sym].complete_date, WorkItem::DATE_FORMAT), :y => 100, :r => 5}],
                   :backgroundColor => "#00ad26",
                   :hoverBackgroundColor => "#00ad26"})
    datasets.push({:label => "Target",
                   :data => [{:x => Date.strptime(@target_date, WorkItem::DATE_FORMAT), :y => determine_target_percentile, :r => 5}],
                   :backgroundColor => "#464AF7",
                   :hoverBackgroundColor => "#464AF7"})

    datasets
  end


  private def build_options
    {
        scales: {
            xAxes: [{
                        type: 'time',
                        time: {
                            unit: determine_time_unit
                        },
                        scaleLabel: {
                            display: true,
                            labelString: "Date"
                        }

                    }],
            yAxes: [{
                        ticks: {
                            beginAtZero: true,
                            :stepSize => 5,
                            :min => 0,
                            :max => 100
                        },
                        scaleLabel: {
                            display: true,
                            labelString: "Percentile Complete"
                        }
                    }]
        }
    }

  end

  private def determine_time_unit
    time_unit = 'day'

    if (determine_max_x_axis - determine_min_x_axis).to_i > 40
      time_unit = 'week'
    end
    time_unit
  end

  private def determine_min_x_axis
    Date.strptime(@forecasts["percentile0".to_sym].complete_date, WorkItem::DATE_FORMAT)
  end

  private def determine_max_x_axis
    Date.strptime(@forecasts["percentile100".to_sym].complete_date, WorkItem::DATE_FORMAT)
  end

  private def determine_target_percentile
    percentile = 0
    target_date = Date.strptime(@target_date, WorkItem::DATE_FORMAT)
    @forecasts.each { |key, forecast|
      if target_date > Date.strptime(forecast.complete_date, WorkItem::DATE_FORMAT) && forecast.percentile < 100
         percentile = forecast.percentile + 5
      end
    }
    percentile
  end

end