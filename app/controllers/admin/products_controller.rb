class Admin::ProductsController < Admin::BaseController
  before_action :find_product,only: [:edit, :update, :destroy]
  def index
    @products = Product.all.includes(:vendor)
  end

  def new
    @product = Product.new
    @product.skus.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_products_path, notice: '商品新增成功'
    else
      render :new, notice: '商品新增失敗'
    end
  end

  def edit
  end
  
  def update
    if @product.update(product_params)
      redirect_to edit_admin_product_path, notice:'商品更新成功'
    else
      render :edit, notice: '商品更新失敗'
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: '商品已刪除'
  end
  
  
  
  private
  def product_params
    params.require(:product).permit(:name,
                                    :vendor_id,
                                    :list_price,
                                    :sell_price,
                                    :on_sell,
                                    :description,
                                    :cover_image,
                                    :category_id,
                                    skus_attributes:[
                                      :id, :spec, :quantity, :_destroy
                                    ] )
  end

  def find_product
    @product = Product.friendly.find(params[:id])
  end
  
end
