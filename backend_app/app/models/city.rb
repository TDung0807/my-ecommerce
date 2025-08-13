class City < ApplicationRecord
    has_many :addresses, dependent: :destroy
end
