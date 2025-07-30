class Setting < ApplicationRecord
  def self.load_all_as_json
    all.map { |s| [s.key, s.value] }.to_h
  end
end
