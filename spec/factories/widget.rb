FactoryGirl.define do
  sequence(:identifier) { |n| "w-#{n}" }

  factory :widget do
    customer_id 1
    identifier
    description { (0...50).map { ('a'..'z').to_a[rand(26)] }.join }
  end
end
