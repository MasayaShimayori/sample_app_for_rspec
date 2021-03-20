FactoryBot.define do
  factory :user do
    email { "hoge@user.com" }
    password { "123" }
    password_confirmation { "123" }
  end
end
