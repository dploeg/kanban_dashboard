require 'dashing/app'
require_relative 'widget_renderer'

class ForecastWidgetRenderer < WidgetRenderer

  def initialize
    super('forecast')
  end

  def prepare(work_items, configuration = Hash.new, data = Hash.new)
    @forecasts = data[:forecasts]
  end

  def build_output_hash
    output = Hash.new

    output[:hrows] = build_heading_rows
    output[:rows] = build_rows_data

    output
  end

  private def build_heading_rows
    [
        {:cols => [{:value => 'Likelihood'}, {:value => 'Duration (weeks)'}, {:value => 'Completion Date'}]}
    ]
  end

  private def build_rows_data
    rows = Array.new
    @forecasts.to_a.reverse.to_h.each { |key, value|
      background_color = case
                           when value.percentile < 50
                             'background-color:#f5e5d7;'
                           when value.percentile < 85
                             'background-color:#fbf2cd;'
                           else
                             'background-color:#cedeb5;'
                         end

      rows.push({:cols => [{:value => value.percentile.to_s + "%"}, {:value => value.duration_weeks}, {:value => value.complete_date}],
                 :style => background_color})
    }
    rows
  end

end