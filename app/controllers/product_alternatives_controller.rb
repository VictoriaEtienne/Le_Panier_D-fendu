class ProductAlternativesController < ApplicationController
  def index
    @product_alternatives = ProductAlternative.all
  end

  def show
    @product_alternative = ProductAlternative.find(params[:id])
  end

  def search
    @product_alternative = ProductAlternative.find_by(bar_code: params[:bar_code])
    # @product_alternative = ProductAlternative.find_by(bar_code: "ABC-abc-1234")
    render json: { redirect_to: product_alternative_path(@product_alternative) }
    # render json: @product_alternative
  end
end
