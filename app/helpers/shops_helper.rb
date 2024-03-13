module ShopsHelper
  def shop_open?(shop)
    current_time = Time.now
    opening_time = Time.parse("10:00 AM")
    closing_time = Time.parse("8:00 PM")

    current_time.between?(opening_time, closing_time)
  end
end
