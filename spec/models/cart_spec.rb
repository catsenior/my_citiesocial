require 'rails_helper'

RSpec.describe Cart, type: :model do
  
  let(:cart) {Cart.new}

  context "基本功能" do
    it "把商品丟到購物車，購物車就有商品" do
      cart.add_item(2)
      #expect(cart.empty?).to be false
      except(cart).not_to be_empty
    end

    it "加了相同種類項目，購買項目不會增加，只有商品數量會改變" do

      3.times{cart.add_item(1)}
      2.times{cart.add_item(2)}
      
      expect(cart.items.count).to be 2
      expect(cart.items.first.quantity).to be 3
    end

    it "商品可以放到購物車，也可以將商品移除" do

      p1 = create(:product)
      cart.add_item(p1.id)

      expect(cart.items.first.product).to be_a Product

    end

    it "計算整台購物車的金額" do

      p1 = create(:product, sell_price: 5)
      p2 = create(:product, sell_price: 10)

      3.times {cart.add_item(p1.id)}
      2.times {cart.add_item(p2.id)}

      expect(cart.total_price).to eq 35

    end
  end

  context "進階功能" do

    it "可以將購物車內容轉換成 Hash，存到 Session 裡" do

      p1 = create(:product)
      p2 = create(:product)

      3.times {cart.add_item(p1.id)}
      2.times {cart.add_item(p2.id)}

      expect(cart.serialize).to eq cart_hash
    end

    it "存放在session的hash還原成購物車的內容" do
      cart = Cart.from_hash(cart_hash)  

      expect(cart.items.first.quantity).to be 3
    end

  private
    def cart_hash
      {
        "items" => [
          {"product_id" => 1, "quantity" => 3},
          {"product_id" => 2, "quantity" => 2},
        ]
      }
    end
  end
end
