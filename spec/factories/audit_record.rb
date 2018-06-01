# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :audit_record do
    customer_id 1
    sequence(:model_id)
    model_type_id { rand(100_000) }
    action 'create'
    description { (0...50).map { ('a'..'z').to_a[rand(26)] }.join }
  end
end
