require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/model/work_item'
require_relative '../../../lib/processor/widgets/started_vs_finished_widget_processor'

module StartedVsFinishedTestHelper

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

  private def check_labels(output_hash)
    labels = output_hash['labels']
    assert_equal 3, labels.size
    assert_equal "2016-10", labels[0]
    assert_equal "2016-11", labels[1]
    assert_equal "2016-12", labels[2]
  end


end