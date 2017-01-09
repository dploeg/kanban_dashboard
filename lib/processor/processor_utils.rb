
module ProcessorUtils
  STANDARD_CLASS_OF_SERVICE = "Standard"

  def sort_into_classes_of_service(work_items)
    classes_of_service = Hash.new
    work_items.each {
        |item|
      if item.class_of_service.nil?
        unless classes_of_service.has_key?(STANDARD_CLASS_OF_SERVICE)
          classes_of_service[STANDARD_CLASS_OF_SERVICE] = Array.new
        end
        classes_of_service[STANDARD_CLASS_OF_SERVICE].push(item)
      else
        unless classes_of_service.include?(item.class_of_service)
          classes_of_service[item.class_of_service] = Array.new
        end
        classes_of_service[item.class_of_service].push(item)
      end
    }
    classes_of_service
  end

end