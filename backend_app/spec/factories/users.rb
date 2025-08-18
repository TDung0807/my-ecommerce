# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email)        { |n| "user#{n}@example.com" }
    password                { "password" }
    name                    { "Test User" }
    sequence(:phone_number) { |n| "09#{format('%08d', n)}" } # 10 số, luôn duy nhất
  end
end
