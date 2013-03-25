require 'test_helper'

class CrossAssociationScoresControllerTest < ActionController::TestCase
  setup do
    @cross_association_score = cross_association_scores(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cross_association_scores)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cross_association_score" do
    assert_difference('CrossAssociationScore.count') do
      post :create, cross_association_score: { ranks: @cross_association_score.ranks, relative_ranks: @cross_association_score.relative_ranks, score: @cross_association_score.score }
    end

    assert_redirected_to cross_association_score_path(assigns(:cross_association_score))
  end

  test "should show cross_association_score" do
    get :show, id: @cross_association_score
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cross_association_score
    assert_response :success
  end

  test "should update cross_association_score" do
    put :update, id: @cross_association_score, cross_association_score: { ranks: @cross_association_score.ranks, relative_ranks: @cross_association_score.relative_ranks, score: @cross_association_score.score }
    assert_redirected_to cross_association_score_path(assigns(:cross_association_score))
  end

  test "should destroy cross_association_score" do
    assert_difference('CrossAssociationScore.count', -1) do
      delete :destroy, id: @cross_association_score
    end

    assert_redirected_to cross_association_scores_path
  end
end
