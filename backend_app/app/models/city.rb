class City < ApplicationRecord
    has_many :addresses, dependent: :destroy
    validates :name, presence: true
    validates :code, presence: true, uniqueness: true
    before_validation :ensure_code

    private

    def ensure_code
        return if code.present?
        self.code = self.class.slugify(name)
    end

    def self.slugify(str)
        ascii = I18n.transliterate(str.to_s)
        ascii.upcase.gsub(/[^A-Z0-9]+/, "_").gsub(/_{2,}/, "_").gsub(/^_|_$/, "")
    end
end
