module ChartDataBuilder

  MAX_Y_AXIS_STEPS = 10

  private def add_formatting_to_dataset(data, background, border, dataset_size)
    background_colors = Array.new
    border_colors = Array.new
    (0..dataset_size-1).each {
      background_colors.push(background)
      border_colors.push(border)
    }
    data[:backgroundColor] = background_colors
    data[:borderColor] = border_colors
    data[:borderWidth] = 1
  end

  def build_output_hash
    output = Hash.new
    output[:labels] = build_labels #labels on the x axis
    output[:datasets] = build_datasets
    output[:options] = build_options
    output
  end

  def build_options
    {
        scales: {
            yAxes: [{
                        stacked: false,
                        ticks: {
                            min: 0,
                            stepSize: determine_y_axis_step_size,
                            max: determine_max_y_axis
                        }
                    }]
        }
    }
  end

  def determine_y_axis_step_size
    rounded_max_y = determine_max_y_axis

    rounded_max_y / MAX_Y_AXIS_STEPS > 1 ? rounded_max_y / MAX_Y_AXIS_STEPS : 1
  end


  def roundup(number, factor)
    return number if number % factor == 0   # already a factor of 10
    return number + factor - (number % factor)  # go to nearest factor 10
  end


end