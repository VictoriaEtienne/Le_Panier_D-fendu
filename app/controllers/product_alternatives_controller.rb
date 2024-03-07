class ProductAlternativesController < ApplicationController
  def index
    @product_alternatives = ProductAlternative.all
  end

  def show
    @product_alternative = ProductAlternative.find(params[:id])
  end

  def search
    # result = ProductAlternative.find_by(bar_code: params[:bar_code]).product.name
    render json: { product: "kiwi" }
  end
end
