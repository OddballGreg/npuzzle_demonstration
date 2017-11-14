require 'test_helper'

class NpuzzleControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get npuzzle_index_url
    assert_response :success
  end

end
