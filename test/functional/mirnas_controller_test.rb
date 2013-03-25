require 'test_helper'

class MirnasControllerTest < ActionController::TestCase
  setup do
    @mirna = mirnas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mirnas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mirna" do
    assert_difference('Mirna.count') do
      post :create, mirna: { name: @mirna.name }
    end

    assert_redirected_to mirna_path(assigns(:mirna))
  end

  test "should show mirna" do
    get :show, id: @mirna
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mirna
    assert_response :success
  end

  test "should update mirna" do
    put :update, id: @mirna, mirna: { name: @mirna.name }
    assert_redirected_to mirna_path(assigns(:mirna))
  end

  test "should destroy mirna" do
    assert_difference('Mirna.count', -1) do
      delete :destroy, id: @mirna
    end

    assert_redirected_to mirnas_path
  end
end
