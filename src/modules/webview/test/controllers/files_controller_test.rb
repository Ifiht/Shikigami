require "test_helper"

class FilesControllerTest < ActionDispatch::IntegrationTest
  test "should get ls" do
    get files_ls_url
    assert_response :success
  end
end
