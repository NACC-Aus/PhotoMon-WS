# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :site do
    sequence(:name){|n| "site#{n}"}
    latitude 12.556
    longitude 156.466
  end
end
