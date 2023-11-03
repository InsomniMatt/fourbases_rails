class RollingData
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :response
  def calculate_segment(data_segment)
    raise "Implement this method in sub class"
  end

  def calculate_rolling_average(data_set, length, calc_call)
    calculating_set = data_set.slice!(0, length)
    until data_set.count < length do
      response << calculate_segment(calculating_set)
      calculating_set.drop(1) << data_set.slice!(0, 1)
    end
    response
  end

end