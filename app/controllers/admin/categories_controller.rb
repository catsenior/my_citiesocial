class Admin::CategoriesController < Admin::BaseController
  before_action :find_category,only: [:edit, :update, :destroy, :sort]
  def index
    @categories = Category.order(position: :asc)
  end

  def sort
    @category.insert_at(params[:to].to_i + 1)
    render json:{status: 'ok'}
  end
  
  
  def new
    @category = Category.new
  end
  
  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to admin_categories_path, notice: '新增成功'
    else
      render :new, notice: '新增失敗'
    end
  end

  def edit
  end
  
  def update
    if @category.update(category_params)
      redirect_to edit_admin_category_path,notice: '更新成功'
    else
      render :edit,notice: '更新失敗'
    end
  end
  

  def destroy
    @category.destroy
    redirect_to admin_categories_path, notice: '資料已刪除'
  end
  
  private
  def category_params
    params.require(:category).permit(:name)
  end
  
  def find_category
    @category = Category.find(params[:id])
  end
  
end
