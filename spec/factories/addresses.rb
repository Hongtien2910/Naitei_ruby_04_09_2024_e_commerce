FactoryBot.define do
  factory :address do
    receiver_name { Faker::Name.name }
    place { Faker::Address.full_address }
    phone { Faker::Number.number(digits: 10).to_s }
    default { false }
    association :user
  end
end
