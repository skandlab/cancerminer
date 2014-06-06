class InfoController < ApplicationController
  layout "info"
  # GET /cancer_types
  # GET /cancer_types.json
  def version
    @cancer_types = CancerType.all

    respond_to do |format|
      format.html
      format.json { render json: @cancer_types }
    end
  end

  def about

    respond_to do |format|
      format.html
    end
    
  end

  def download

    respond_to do |format|
      format.html
    end
    
  end

  
end
