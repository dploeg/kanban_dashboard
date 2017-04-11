require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/model/work_item'
require_relative '../../../lib/processor/widgets/started_vs_completed_widget_renderer'

module StartedVsCompletedTestHelper

  private def check_formatting_started(dataset)
     check_settings(dataset[:backgroundColor], 'rgba(227, 175, 116, 1)', dataset[:data].size)
     check_settings(dataset[:borderColor], 'rgba(190, 120, 39, 1)', dataset[:data].size)
     assert_equal 1, dataset[:borderWidth]
   end

   private def check_formatting_completed(dataset)
     check_settings(dataset[:backgroundColor], 'rgba(161, 192, 229, 1)', dataset[:data].size)
     check_settings(dataset[:borderColor], 'rgba(44, 96, 160, 1)', dataset[:data].size)
     assert_equal 1, dataset[:borderWidth]
   end

   private def check_settings(setting_array, setting, number_of_elements)
     assert_equal number_of_elements, setting_array.size
     setting_array.each { |background|
       assert_equal setting, background
     }
   end

  private def check_labels(output_hash)
    labels = output_hash[:labels]
    assert_equal 3, labels.size
    assert_equal "2016-10", labels[0]
    assert_equal "2016-11", labels[1]
    assert_equal "2016-12", labels[2]
  end


end