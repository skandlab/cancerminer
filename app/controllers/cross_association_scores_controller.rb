class CrossAssociationScoresController < ApplicationController
  # GET /cross_association_scores
  # GET /cross_association_scores.json
  def index
  end

  # GET /cross_association_scores/1
  # GET /cross_association_scores/1.json
  def show
    @cross_association_score = CrossAssociationScore.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cross_association_score }
      format.js
    end
  end

end
