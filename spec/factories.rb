FactoryGirl.define do
  factory :event do
    stripe_id "123"
    data {{
      "id" => "123"
    }}
  end
end

