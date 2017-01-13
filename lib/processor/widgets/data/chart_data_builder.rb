module ChartDataBuilder

  MAX_STEPS = 10

  private def add_formatting_to_dataset(data, background, border, dataset_size)
    background_colors = Array.new
    border_colors = Array.new
    (0..dataset_size-1).each {
      background_colors.push(background)
      border_colors.push(border)
    }
    data['backgroundColor'] = background_colors
    data['borderColor'] = border_colors
    data['borderWidth'] = 1
  end

  def build_output_hash
    output = Hash.new
    output['labels'] = build_labels
    output['datasets'] = build_datasets
    output['options'] = build_options
    output
  end

  def build_options
    options = Hash.new
    options['scales'] = {'yAxes' => [{'stacked' => false, 'ticks' => {'min' => 0, 'stepSize' => determine_step_size, 'max' => determine_max_y_axis}}]}
    options
  end

  def determine_step_size
    rounded_max_y = determine_max_y_axis

    rounded_max_y / MAX_STEPS > 1 ? rounded_max_y / MAX_STEPS : 1
  end


  def roundup(number)
    return number if number % 10 == 0   # already a factor of 10
    return number + 10 - (number % 10)  # go to nearest factor 10
  end


end