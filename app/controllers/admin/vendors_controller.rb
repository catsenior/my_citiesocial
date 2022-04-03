class Admin::VendorsController < Admin::BaseController
  before_action :find_vendor,only: [:edit, :update,:destroy]
  def index
    @vendors = Vendor.all
  end

  def new
    @vendor =  Vendor.new
  end
  
  def create
    @vendor =  Vendor.new(vendor_params)
    if @vendor.save
      redirect_to admin_vendors_path, notice:'新增廠商成功'
    else
      render :new, notice:'新增廠商失敗'
    end
  end

  def edit
  end
  
  def update
    if @vendor.update(vendor_params)
      redirect_to edit_admin_vendor_path(@vendor), notice:'更新成功'
    else
      render :edit, notice:'更新失敗'
    end
  end

  def destroy
    @vendor.destroy
    redirect_to admin_vendors_path, notice: '廠商已刪除'
  end
  
  private
  def vendor_params
    params.require(:vendor).permit(:title, :description, :online)
  end
  
  def find_vendor
    @vendor = Vendor.find(params[:id])
  end
  
end
