FactoryBot.define do
  factory :task do
    title { "hoge" }
    content { "hogehoge" }
    status { :todo }
    deadline { 1.week.from_now }
    association :user
  end
end
