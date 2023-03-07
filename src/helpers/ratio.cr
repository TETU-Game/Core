module Ratio
  alias IdValue = Hash(String, Number)

  # minimum ratio of right/left, or nil if missing keys in right
  def self.minimum_reverse(left : IdValue, right : IdValue)
    return nil if left.keys & right.keys != left.keys

    left.map do |id, left_value|
      right_value = right[id]
      right_value / left_value
    end.min
  end

  # minimum ratio of left/right, or nil if missing keys in right
  def self.minimum(left : IdValue, right : IdValue)
    return nil if left.keys & right.keys != left.keys

    left.map do |id, left_value|
      right_value = right[id]
      left_value / right_value
    end.min
  end
end
