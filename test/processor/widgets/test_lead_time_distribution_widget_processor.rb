require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/processor/widgets/lead_time_percentile_summary_widget_processor'

class TestLeadTimeDistributionWidgetProcessor < Minitest::Test

  EXPEDITE = "Expedite"
  FIXED_DATE = "Fixed Date"
  INTANGIBLE = "Intangible"
  STANDARD = "Standard"

  context 'LeadTimeDistributionWidgetProcessor' do

    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16"),
                     WorkItem.new(:start_date => "15/3/16", :complete_date => "21/3/16"),
                     WorkItem.new(:start_date => "12/3/16", :complete_date => "14/4/16"),
                     WorkItem.new(:start_date => "19/3/16", :complete_date => "19/4/16"),
                     WorkItem.new(:start_date => "21/3/16", :complete_date => "17/4/16"),
                     WorkItem.new(:start_date => "28/3/16", :complete_date => "22/4/16"),
                     WorkItem.new(:start_date => "2/4/16", :complete_date => "25/4/16", :class_of_service => STANDARD),
                     WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16"),

                     WorkItem.new(:start_date => "3/4/16", :complete_date => "12/4/16", :class_of_service => EXPEDITE),
                     WorkItem.new(:start_date => "2/4/16", :complete_date => "13/4/16", :class_of_service => FIXED_DATE),
                     WorkItem.new(:start_date => "5/4/16", :complete_date => "25/4/16", :class_of_service => INTANGIBLE),
                     WorkItem.new(:start_date => "6/4/16", :complete_date => "13/4/16", :class_of_service => EXPEDITE),
                     WorkItem.new(:start_date => "7/4/16", :complete_date => "14/4/16", :class_of_service => EXPEDITE),
                     WorkItem.new(:start_date => "6/4/16", :complete_date => "28/4/16", :class_of_service => FIXED_DATE),
                     WorkItem.new(:start_date => "13/4/16", :complete_date => "12/5/16", :class_of_service => INTANGIBLE),
      ]

    end

    should 'output hash' do
      widget = LeadTimeDistributionWidgetProcessor.new
      widget.process @work_items

      output_hash = widget.build_output_hash
      check_output(output_hash)

    end

  end

  private def check_output(output)
    assert_equal 3, output.keys.size

    check_output_labels(output)
    assert_equal 1, output['options'].size
    assert_equal 1, output['options']['scales']['yAxes'][0]['ticks']['stepSize']
    check_datasets(output)

  end

  def check_datasets(output)
    assert_equal 1, output['datasets'].size
    planned = output['datasets'][0]
    assert_equal planned['label'], 'Planned'

    assert_same_elements [1, 2, 2, 2, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0], planned['data']

    check_formatting(planned)
  end

  def check_formatting(planned)
    check_settings(planned['backgroundColor'], 'rgba(255, 99, 132, 0.2)')
    check_settings(planned['borderColor'], 'rgba(255, 99, 132, 1)')
    assert_equal 1, planned['borderWidth']
  end

  def check_settings(setting_array, setting)
    assert_equal 20, setting_array.size
    setting_array.each { |background|
      assert_equal setting, background
    }
  end

  def check_output_labels(output)
    labels = output['labels']
    assert_equal 20, labels.size
    counter = 0
    min = 6
    increments = 2
    labels.each { |label|
      assert_equal min + counter * increments, label
      counter=counter+1
    }
  end

end