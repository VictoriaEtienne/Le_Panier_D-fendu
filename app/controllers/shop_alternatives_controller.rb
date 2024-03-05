class ShopAlternativesController < ApplicationController
  def index
    @shop_alternatives = ShopAlternative.all
  end

  def show
    @shop_alternative = ShopAlternative.find(params[:id])
  end
end
