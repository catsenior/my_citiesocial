import { Controller } from "stimulus"
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = ["quantity", "sku", "addToCartButton"]

  quantity_minus(evt) {
    evt.preventDefault();
    let q = Number(this.quantityTarget.value);
    if (q > 1) {
      this.quantityTarget.value = q - 1;
    }
  }
  quantity_plus(evt) {
    evt.preventDefault();
    let q = Number(this.quantityTarget.value);
    this.quantityTarget.value = q + 1;
  }

  add_to_cart(evt) {
    evt.preventDefault();

    let product_id = this.data.get("id");
    let quantity = this.quantityTarget.value;
    let sku = this.skuTarget.value;

    if (quantity > 0) {
      this.addToCartButtonTarget.classList.add('is-loading');
      let data = new FormData();
      data.append("id", product_id);
      data.append("quantity", quantity);
      data.append("sku", sku);

      Rails.ajax({
        url: "/api/v1/cart",
        type: 'POST',
        data: data,
        success: (response) => {
          if (response.status === 'ok') {
            let item_count = response.items || 0;
            let evt = new CustomEvent('addToCart', { 'detail': { item_count: item_count } });
            document.dispatchEvent(evt);
          }
          console.log(response);
        },
        error: err => {
          console.log(err);
        },
        complete: () => {
          this.addToCartButtonTarget.classList.remove('is-loading');
        }
      });
    }
  }
}