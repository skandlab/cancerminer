require 'test_helper'

class AssociationScoresControllerTest < ActionController::TestCase
  setup do
    @association_score = association_scores(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:association_scores)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create association_score" do
    assert_difference('AssociationScore.count') do
      post :create, association_score: { method: @association_score.method, score: @association_score.score }
    end

    assert_redirected_to association_score_path(assigns(:association_score))
  end

  test "should show association_score" do
    get :show, id: @association_score
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @association_score
    assert_response :success
  end

  test "should update association_score" do
    put :update, id: @association_score, association_score: { method: @association_score.method, score: @association_score.score }
    assert_redirected_to association_score_path(assigns(:association_score))
  end

  test "should destroy association_score" do
    assert_difference('AssociationScore.count', -1) do
      delete :destroy, id: @association_score
    end

    assert_redirected_to association_scores_path
  end
end
