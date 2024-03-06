class ShopsController < ApplicationController
  def index
    @shops = Shop.all
    @markers = @shops.geocoded.map do |shop|
      {
        lat: shop.latitude,
        lng: shop.longitude,
        info_window_html: render_to_string(partial: "info_window", locals: { shop: shop }),
        marker_html: render_to_string(partial: "marker", locals: {shop: shop}),
      }
    end
  end

  def all_shops
    @shops = Shop.all
  end

  def show
    @shop = Shop.find(params[:id])
  end
end
