class HistoriesController < ApplicationController
  def index
    @histories = History.all
  end

  def show
    @history = History.find(params[:id])
  end

  def create
    @history = History.new(history_params)
    @history.user = current_user
    @product_alternative = ProductAlternative.find_by(bar_code: params[:history][:barcode])
    # @product_alternative = ProductAlternative.first
    @history.scanned_product_alternative = @product_alternative
    if @product_alternative && @history.save
      redirect_to product_alternative_path(@product_alternative)
    else
      render :new
    end
  end

  def new
    @history = History.new
  end

  def destroy
    @history = History.find(params[:id])
    @history.destroy
    redirect_to histories_path, status: :see_other
  end

  private

  def history_params
    params.require(:history).permit(:lat, :lng)
  end
end
