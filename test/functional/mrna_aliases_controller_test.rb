require 'test_helper'

class MrnaAliasesControllerTest < ActionController::TestCase
  setup do
    @mrna_alias = mrna_aliases(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mrna_aliases)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mrna_alias" do
    assert_difference('MrnaAlias.count') do
      post :create, mrna_alias: { alias: @mrna_alias.alias }
    end

    assert_redirected_to mrna_alias_path(assigns(:mrna_alias))
  end

  test "should show mrna_alias" do
    get :show, id: @mrna_alias
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mrna_alias
    assert_response :success
  end

  test "should update mrna_alias" do
    put :update, id: @mrna_alias, mrna_alias: { alias: @mrna_alias.alias }
    assert_redirected_to mrna_alias_path(assigns(:mrna_alias))
  end

  test "should destroy mrna_alias" do
    assert_difference('MrnaAlias.count', -1) do
      delete :destroy, id: @mrna_alias
    end

    assert_redirected_to mrna_aliases_path
  end
end
