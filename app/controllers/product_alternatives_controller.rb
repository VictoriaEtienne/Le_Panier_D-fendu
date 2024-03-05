class ProductAlternativesController < ApplicationController
  def index
    @product_alternatives = ProductAlternative.all
  end

  def show
    @product_alternative = ProductAlternative.find(params[:id])
  end
end
