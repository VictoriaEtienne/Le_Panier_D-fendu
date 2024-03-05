require "test_helper"

class ProductAlternativesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get product_alternatives_index_url
    assert_response :success
  end

  test "should get show" do
    get product_alternatives_show_url
    assert_response :success
  end
end
