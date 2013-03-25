require 'test_helper'

class MrnasControllerTest < ActionController::TestCase
  setup do
    @mrna = mrnas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mrnas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mrna" do
    assert_difference('Mrna.count') do
      post :create, mrna: { name: @mrna.name }
    end

    assert_redirected_to mrna_path(assigns(:mrna))
  end

  test "should show mrna" do
    get :show, id: @mrna
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mrna
    assert_response :success
  end

  test "should update mrna" do
    put :update, id: @mrna, mrna: { name: @mrna.name }
    assert_redirected_to mrna_path(assigns(:mrna))
  end

  test "should destroy mrna" do
    assert_difference('Mrna.count', -1) do
      delete :destroy, id: @mrna
    end

    assert_redirected_to mrnas_path
  end
end
