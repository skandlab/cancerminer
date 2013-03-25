# -*- coding: utf-8 -*-
class SearchController < ApplicationController
  layout "application"
  protect_from_forgery :only => [:create, :update, :destroy]
  
  def mirnas
    return [] if params[:term].nil? or params[:term].size < 2
    res = Mirna.where("name ILIKE ?", "%"+params[:term]+"%")
    render json: res.map{|x| Hash[label: x.name, href: x.id]} 
  end

  def mrnas
    return [] if params[:term].nil? or params[:term].size < 2
    res = Mrna.where("symbol ILIKE ?", "%"+params[:term]+"%")
    render json: res.map{|x| Hash[label: x.symbol, href: x.id]} 
  end

  def pathways
    return [] if params[:term].nil? or params[:term].size < 3
    res = Pathway.where("name ILIKE ?", "%"+params[:term]+"%")
    render json: res.map{|x| Hash[label: x.name, href: x.id]} 
  end

  
  def pairs
    @cas = nil

    flash[:alert] = []
    
    mirna_id = (params[:miRNA].blank? or params[:miRNA] == 'miRNA') ? '' : params[:miRNA]
    mrna_id = (params[:mRNA].blank? or params[:mRNA] == 'mRNA') ? '' : params[:mRNA]
    pathway_id = (params[:pathway].blank? or params[:pathway] == 'gene set / pathway') ? '' : params[:pathway]

    params[:miRNA] = 'miRNA' if params[:miRNA].blank?
    params[:mRNA] = 'mRNA' if params[:mRNA].blank?
    params[:pathway] = 'gene set / pathway' if params[:pathway].blank?

    if !mirna_id.empty?
      mirna = Mirna.where("name = ?",mirna_id).first ||  Mirna.where("name ILIKE ?", "%"+mirna_id+"%").first
      if !mirna.nil?
        @cas = (@cas || CrossAssociationScore).where("mirna_id" => mirna.id)
      else
        flash[:alert] << "No data found for miRNA (#{mirna_id})"
      end
    end
    
    if !mrna_id.empty? and flash[:alert].empty?
      mrna = Mrna.where("symbol = ?",mrna_id).first || Mrna.where("symbol ILIKE ?", "%"+mrna_id+"%").first
      if !mrna.nil?
        @cas = (@cas || CrossAssociationScore).where("mrna_id" => mrna.id)
      else
        flash[:alert] << "No data found for mRNA (#{mrna_id})"
      end
    end
    
    if !pathway_id.empty? and flash[:alert].empty?
      pathway = Pathway.where("name = ?",pathway_id).first
      if !pathway.nil?
        @cas = (@cas || CrossAssociationScore).joins(:mrna => :pathways).where("pathways.id" => pathway.id)
      else
        flash[:alert] << "No data found for pathway (#{pathway_id})"
      end
    end

    # various parameters
    filter_by_ctype_ids = CancerType.all.select{|x| params["#{x.name}_sig"]}.map{|x| x.id}
    sort_order = ((params.key?(:association) and params[:association] == 'pos') ? 'DESC' : 'ASC')

    @cas = CrossAssociationScore if @cas.nil?
      
    ### normal filter and sort, miRNA, mRNA or pathway specified
    sig_threshold = 2
    sort_order = ((params.key?(:association) and params[:association] == 'pos') ? 'DESC' : 'ASC')
    
    # filter
    if !filter_by_ctype_ids.empty?

      cast = CrossAssociationScore.arel_table
      ast = AssociationScore.arel_table #alias?
      # we need to alias ast - otherwise it is referenced twice ...
      subq = AssociationScore.select('as2.cross_association_score_id').from('association_scores as2')
      subq = subq.where('as2.cross_association_score_id = cross_association_scores.id')
      
      subq = subq.where('as2.cancer_type_id' => filter_by_ctype_ids)
            
      subq = (sort_order == 'ASC') ? subq.where('as2.score_regr < ?',-sig_threshold) : subq.where('as2.score_regr > ?',sig_threshold)
      subq = subq.group('as2.cross_association_score_id').having("count(as2.cancer_type_id) = #{filter_by_ctype_ids.size}")
      
      @cas = @cas.where(subq.exists)
        
    end
    
    if params['cross_sig']
      @cas = (sort_order == 'ASC') ? @cas.where('score < ?',-sig_threshold) : @cas = @cas.where('score > ?',sig_threshold)
    end
    
    # sort
    if params[:ctype_sort] != 'cross'
      # look up cancer type
      ctype = CancerType.where("name" => params[:ctype_sort]).first
      if ctype
        @cas = @cas.joins(:association_scores).where('association_scores.cancer_type_id' => ctype.id).order("association_scores.score_regr #{sort_order}")
      else
        # ctype not found
        @cas = @cas.order("score #{sort_order}")
      end
    else
      # sort by cross score
      @cas = @cas.order("score #{sort_order}")
    end
    
    # filter associations without predicted sites
    if params.key?(:targets) and params[:targets] == 'hide'
      @cas = @cas.where('is_target = ?','1')
    end
    
    # total_entries is implemted in fork on github
    @cas = @cas.paginate(:page => params[:page], :per_page => 20, :total_entries => -1)

    @cas = @cas.includes([:mirna,:mrna])
    
    # debug
    # puts @cas.explain if @cas

    # much faster if we load data here ...
    @cas = @cas.all
    
    render 'search/index'
  end

end
