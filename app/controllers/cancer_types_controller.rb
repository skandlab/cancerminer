class CancerTypesController < ApplicationController
  # GET /cancer_types
  # GET /cancer_types.json
  def index
    @cancer_types = CancerType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cancer_types }
    end
  end

end
