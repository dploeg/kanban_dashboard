require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/processor/widgets/started_vs_finished_widget_processor'

class TestStartedVsFinishedWidgetProcessor < Minitest::Test

  EXPEDITE = "Expedite"
  FIXED_DATE = "Fixed Date"
  INTANGIBLE = "Intangible"
  STANDARD = "Standard"


  context 'StartedVsFinishedWidgetProcessor' do

    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")]
    end

    should "create a base output hash of data for a single item" do
      output_hash = process_and_build_output_hash
      assert_equal 2, output_hash['datasets'].size
      started = output_hash['datasets'][0]
      assert_equal started['label'], 'Started'
      completed = output_hash['datasets'][1]
      assert_equal completed['label'], 'Completed'

      assert_equal [1,0,0], started['data']
      assert_equal [0,0,1], completed['data']
    end

    should "color started and completed for a single item" do
      output_hash = process_and_build_output_hash

      check_formatting_started(output_hash['datasets'][0])
      check_formatting_completed(output_hash['datasets'][1])
    end

    should "set labels for a single item" do
      output_hash = process_and_build_output_hash

      labels = output_hash['labels']
      assert_equal 3, labels.size
      assert_equal "2016-10", labels[0]
      assert_equal "2016-11", labels[1]
      assert_equal "2016-12", labels[2]
    end

    should "create output" do
      widget = StartedVsFinishedWidgetProcessor.new
      widget.process @work_items

      widget.output
    end
  end

  private def check_formatting_started(dataset)
    check_settings(dataset['backgroundColor'], 'rgba(255, 99, 132, 0.2)')
    check_settings(dataset['borderColor'], 'rgba(255, 99, 132, 1)')
    assert_equal 1, dataset['borderWidth']
  end

  private def check_formatting_completed(dataset)
    check_settings(dataset['backgroundColor'], 'rgba(92, 255, 127, 0.2)')
    check_settings(dataset['borderColor'], 'rgba(92, 255, 127, 1)')
    assert_equal 1, dataset['borderWidth']
  end


  private def check_settings(setting_array, setting)
    assert_equal 3, setting_array.size
    setting_array.each { |background|
      assert_equal setting, background
    }
  end

  private def process_and_build_output_hash
    widget = StartedVsFinishedWidgetProcessor.new
    widget.process @work_items

    widget.build_output_hash
  end
end