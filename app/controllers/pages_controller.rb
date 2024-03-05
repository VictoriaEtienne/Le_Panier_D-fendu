class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @user = User.new
    @shops = Shop.all
    @markers = @shops.geocoded.map do |shop|
      {
        lat: shop.latitude,
        lng: shop.longitude,
        info_window_html: render_to_string(partial: "info_window", locals: {shop: shop})
      }
    end
  end

  def update_location
    @user = User.new(user_params)

    if @user.save
      redirect_to root_path, notice: 'Location updated successfully.'
    else
      render :home
    end
  end

  private

  def user_params
    params.require(:user).permit(:latitude, :longitude)
  end
end
