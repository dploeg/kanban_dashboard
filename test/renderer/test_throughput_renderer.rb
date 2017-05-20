require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../lib/renderer/lead_time_percentile_summary_renderer'
require_relative '../../lib/model/work_item'
require_relative 'started_vs_completed_test_helper'
require_relative '../test_constants'

class TestThroughputRenderer < Minitest::Test
  include TestConstants

  context 'ThroughputRenderer' do

    setup do
      @work_items = [WorkItem.new(:start_date => "10/3/16", :complete_date => "21/3/16")]
      @data = {:completed => {"2016-10"=>0, "2016-11"=>0, "2016-12"=>1}}
    end

    should 'output hash for single item' do
      output_hash = process_and_build_output_hash
      check_output(output_hash)
    end

    should 'allow alternate x axis values' do
      renderer = ThroughputRenderer.new(10)
      renderer.prepare @work_items, nil, @data

      output = renderer.build_output_hash

      assert_equal 10, output[:labels].size
    end

    context "incomplete data" do

      should "filter items without a complete date" do
        @work_items.push(WorkItem.new(:start_date => "10/3/16"))
        output_hash = process_and_build_output_hash
        check_output(output_hash)
      end
    end

    should 'call send_event' do
      renderer = ThroughputRenderer.new
      renderer.prepare @work_items, nil, @data

      send_event = MiniTest::Mock.new
      send_event.expect :call, nil, ['throughput', renderer.build_output_hash]
      renderer.stub :send_event, send_event do
        renderer.output
      end

      send_event.verify
    end

  end

  private def process_and_build_output_hash
    renderer = ThroughputRenderer.new
    renderer.prepare @work_items, nil, @data

    renderer.build_output_hash
  end

  private def check_output(output)
    assert_equal 3, output.keys.size

    check_output_labels(output)
    check_options(output)
    check_datasets(output)

  end

  def check_options(output)
    assert_equal 1, output[:options].size
    assert_equal 1, output[:options][:scales][:yAxes][0][:ticks][:stepSize]
    assert_equal false, output[:options][:scales][:yAxes][0][:stacked]
    assert_equal true, output[:options][:scales][:yAxes][0][:scaleLabel][:display]
    assert_equal "Count of weeks with value", output[:options][:scales][:yAxes][0][:scaleLabel][:labelString]

    assert_equal true, output[:options][:scales][:xAxes][0][:scaleLabel][:display]
    assert_equal "Throughput value (number of items completed in a calendar week)", output[:options][:scales][:xAxes][0][:scaleLabel][:labelString]
  end

  def check_datasets(output)
    assert_equal 1, output[:datasets].size
    tp_frequency = output[:datasets][0]
    assert_equal tp_frequency[:label], 'Throughput Frequency'

    assert_same_elements [2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], tp_frequency[:data]
    check_formatting(tp_frequency)
  end

  def check_formatting(tp_frequency)
    check_settings(tp_frequency[:backgroundColor], 'rgba(255, 206, 86, 0.2)', tp_frequency[:data].size)
    check_settings(tp_frequency[:borderColor], 'rgba(255, 206, 86, 1)', tp_frequency[:data].size)
    assert_equal 1, tp_frequency[:borderWidth]
  end

  private def check_settings(setting_array, setting, number_of_values)
    assert_equal number_of_values, setting_array.size
    setting_array.each { |background|
      assert_equal setting, background
    }
  end

  def check_output_labels(output)
    labels = output[:labels]
    assert_equal 20, labels.size
    counter = 0
    min = 0
    increments = 1
    labels.each { |label|
      assert_equal min + counter * increments, label
      counter=counter+1
    }
  end
end
