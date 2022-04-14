FactoryBot.define do
  factory :order do
    num { "MyString" }
    recipient { "MyString" }
    tal { "MyString" }
    address { "MyString" }
    note { "MyText" }
    user { "" }
    state { "MyString" }
    paid_at { "2022-04-13 13:54:29" }
    transaction_id { "MyString" }
  end
end
