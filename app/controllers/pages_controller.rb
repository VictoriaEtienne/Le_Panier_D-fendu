class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @user = User.new
    @shops = Shop.all
  end

  def dashboard
    @user = current_user
    @total_score = @user.total_score
  end

  def increase_score
    current_user.increment!(:total_score)
    render json: { total_score: current_user.total_score }
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
