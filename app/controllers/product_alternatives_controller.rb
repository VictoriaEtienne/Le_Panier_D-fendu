class ProductAlternativesController < ApplicationController
  def index
    @product_alternatives = ProductAlternative.all
  end

  def show
    @product_alternative = ProductAlternative.find(params[:id])
  end

  def search
    # result = ProductAlternative.find_by(bar_code: params[:bar_code]).product.name
    respond_to do |f|
      f.html
      f.json { render json: "kiwi" }
    end
    # render json: result
  end
end
