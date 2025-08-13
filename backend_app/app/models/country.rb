class Country < ApplicationRecord
    has_many :addresses, dependent: :destroy
end
