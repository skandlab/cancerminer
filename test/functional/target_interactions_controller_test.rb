require 'test_helper'

class TargetInteractionsControllerTest < ActionController::TestCase
  setup do
    @target_interaction = target_interactions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:target_interactions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create target_interaction" do
    assert_difference('TargetInteraction.count') do
      post :create, target_interaction: { mirsvr: @target_interaction.mirsvr, tscan_contextscore: @target_interaction.tscan_contextscore, tscan_pct: @target_interaction.tscan_pct }
    end

    assert_redirected_to target_interaction_path(assigns(:target_interaction))
  end

  test "should show target_interaction" do
    get :show, id: @target_interaction
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @target_interaction
    assert_response :success
  end

  test "should update target_interaction" do
    put :update, id: @target_interaction, target_interaction: { mirsvr: @target_interaction.mirsvr, tscan_contextscore: @target_interaction.tscan_contextscore, tscan_pct: @target_interaction.tscan_pct }
    assert_redirected_to target_interaction_path(assigns(:target_interaction))
  end

  test "should destroy target_interaction" do
    assert_difference('TargetInteraction.count', -1) do
      delete :destroy, id: @target_interaction
    end

    assert_redirected_to target_interactions_path
  end
end
