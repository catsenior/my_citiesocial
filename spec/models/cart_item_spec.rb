require 'rails_helper'

RSpec.describe CartItem, type: :model do
  it "每個 cart item 都可以計算自己的金額" do
    cart = Cart.new
    p1 = create(:product, :with_skus, sell_price: 5)
    p2 = create(:product, :with_skus, sell_price: 10)

    3.times {cart.add_sku(p1.skus.first.id)}
    2.times {cart.add_sku(p2.skus.first.id)}

    expect(cart.items.first.total_price).to eq 15
    expect(cart.items.last.total_price).to eq 20
  end
end
