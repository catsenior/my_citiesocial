class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = current_user.orders.order(id: :desc)
  end

  def create
    @order = current_user.orders.build(order_params)

    current_cart.items.each do |item|
      @order.order_items.build(sku_id: item.sku_id, quantity: item.quantity)
    end

    if @order.save
      response = Faraday.post("#{ENV['line_pay_endpoint']}/v2/payments/request") do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['X-LINE-ChannelId'] = ENV['line_pay_channel_id']
        req.headers['X-LINE-ChannelSecret'] = ENV['line_pay_channel_secreat']
        req.body = {
          productName: '大平台',
          amount: current_cart.total_price.to_i,
          currency: 'TWD',
          confirmUrl: 'http://localhost:3000/orders/confirm',
          orderId: @order.num
        }.to_json
      end

      result = JSON.parse(response.body)

      if result['returnCode'] == '0000'
        payment_url = result['info']['paymentUrl']['web']
        redirect_to payment_url
      else
        flash[:notice] = '付款發生錯誤'
        render 'carts/checkout'
      end
    end
  end

  def confirm
    response = Faraday.post("#{ENV['line_pay_endpoint']}/v2/payments/#{params[:transactionId]}/confirm") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-LINE-ChannelId'] = ENV['line_pay_channel_id']
      req.headers['X-LINE-ChannelSecret'] = ENV['line_pay_channel_secreat']
      req.body = {
        amount: current_cart.total_price.to_i,
        currency: 'TWD'
      }.to_json
    end

    result = JSON.parse(response.body)

    if result['returnCode'] == '0000'
      order_id = result['info']['orderId']
      transaction_id = result['info']['transactionId']
      # 變更訂單狀態
      order = current_user.orders.find_by(num: order_id)
      order.pay!(transaction_id: transaction_id)
      # 清空購物車
      session[:cart] = nil
      redirect_to root_path, notice: '付款成功'
    else
      redirect_to root_path, notice: '付款失敗'
    end
  end

  def cancel
    @order = current_user.orders.find(params[:id])
    if @order.paid?
      response = Faraday.post("#{ENV['line_pay_endpoint']}/v2/payments/#{@order.transaction_id}/refund") do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['X-LINE-ChannelId'] = ENV['line_pay_channel_id']
        req.headers['X-LINE-ChannelSecret'] = ENV['line_pay_channel_secreat']
      end

      result = JSON.parse(response.body)

      if result['returnCode'] == '0000'
        @order.cancel!
        redirect_to orders_path, notice: "訂單 #{@order.num} 已取消,並完成退款！"
      else
        redirect_to orders_path, notice: '退款發生錯誤'
      end
    else
      @order.cancel!
      redirect_to orders_path, notice: "訂單 #{@order.num} 已取消！"
    end
  end

  def pay
    @order = current_user.orders.find(params[:id])
    response = Faraday.post("#{ENV['line_pay_endpoint']}/v2/payments/request") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-LINE-ChannelId'] = ENV['line_pay_channel_id']
      req.headers['X-LINE-ChannelSecret'] = ENV['line_pay_channel_secreat']
      req.body = {
        productName: '大平台',
        amount: @order.total_price.to_i,
        currency: 'TWD',
        confirmUrl: "http://localhost:3000/orders/#{@order.id}/pay_confirm",
        orderId: @order.num
      }.to_json
    end
    result = JSON.parse(response.body)

    if result['returnCode'] == '0000'
      payment_url = result['info']['paymentUrl']['web']
      redirect_to payment_url
    else
      redirect_to orders_path, notice: '付款發生錯誤'
    end
  end

  def pay_confirm
    @order = current_user.orders.find(params[:id])
    response = Faraday.post("#{ENV['line_pay_endpoint']}/v2/payments/#{params[:transactionId]}/confirm") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-LINE-ChannelId'] = ENV['line_pay_channel_id']
      req.headers['X-LINE-ChannelSecret'] = ENV['line_pay_channel_secreat']
      req.body = {
        amount: @order.total_price.to_i,
        currency: 'TWD'
      }.to_json
    end

    result = JSON.parse(response.body)

    if result['returnCode'] == '0000'
      transaction_id = result['info']['transactionId']
      # 變更訂單狀態
      @order.pay!(transaction_id: transaction_id)

      redirect_to orders_path, notice: '付款成功'
    else
      redirect_to orders_path, notice: '付款失敗'
    end
  end

  private

  def order_params
    params.require(:order).permit(:recipient, :tel, :address, :note)
  end
end
