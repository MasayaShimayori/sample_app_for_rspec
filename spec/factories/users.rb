FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.com" }
    password { "123" }
    password_confirmation { "123" }
  end
end
