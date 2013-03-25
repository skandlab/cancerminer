require 'fileutils'
require 'pp'

require File.join(File.dirname(__FILE__), '../../config/environment')

#############
### Tasks
#############

namespace :cmir do

  def load_data(num_associations=20,db=nil)
    datadir = "data/"

    # Process cancer types
    puts "loading cancer types ..."
    CancerType.delete_all
    tmp_data = []
    ctype_names = []
    IO.readlines(datadir + "correlations/cancer_types.tsv").each do |l|
      ls = l.chomp.split("\t")
      CancerType.create(:name => ls[0].upcase, :description => ls[1], :sample_count => ls[2].to_i, :color => ls[3])
      ctype_names << ls[0] # ordered list
    end
    ctypes = Hash.new
    CancerType.all.map{|x| ctypes[x.name] = x.id}

    # Process miRNAs
    puts "loading miRNAs ..."
    Mirna.delete_all
    tmp_data = []
    ngenes_pr_ctype = Hash.new
    IO.readlines(datadir + "correlations/cross/genes_in_studies.tsv").sort[0..num_associations].each do |l|
      ls = l.chomp.split("\t")
      mir = ls.shift
      ngenes_pr_ctype[mir] = ls
      Mirna.create(:name => mir)
    end
    mirnas = Hash.new
    Mirna.all.map{|x| mirnas[x.name] = x.id}
    
    # Process mRNAs
    puts "loading mRNAs ..."

    # only use mRNAs for which we have data
    mrnas_with_data = Hash.new
    Dir.glob(datadir+"correlations/cross/hsa-*.tsv").each{|f| IO.readlines(f).each{|x| mid = x.split("\t")[0]; mrnas_with_data[mid] = 1 if !mrnas_with_data.key?(mid)}}
    puts "read #{mrnas_with_data.size} mRNAs with data ..."

    Mrna.delete_all
    tmp_data = []
    IO.readlines(datadir + "resources/hsa_gene_alias.tsv")[1..-1].each do |l|
      ls = l.chomp.split("\t")
      symbol = ls[1]
      name = ls[2]
      # require that symbol or alias have data
      als = (ls[3].nil? ? [] : ls[3].split(", "))
      next if ([symbol] + als).select{|x| mrnas_with_data.key?(x)}.empty?
      Mrna.create(:symbol => symbol, :name => name)
    end
    mrnas = Hash.new
    Mrna.all.map{|x| mrnas[x.symbol] = x.id}
    puts "stored #{mrnas.size} mRNA records"
    
    # Process mRNA alias
    puts "loading mRNA alias ..."
    MrnaAlias.delete_all
    tmp_data = []
    malias = Hash.new # string -> mrna ID
    IO.readlines(datadir + "resources/hsa_gene_alias.tsv")[1..-1].each do |l|
      ls = l.chomp.split("\t")
      next if ls[3].nil?
      next if !mrnas.key?(ls[1])
      mrna = mrnas[ls[1]]
      malias[ls[1]] = mrna
      ls[3].split(", ").each do |al|
        malias[al] = mrna if !malias.key?(al)
        MrnaAlias.create(:alias => al, :mrna_id => mrna)
      end
    end
    puts "stored #{malias.size} mRNA alias records"
    
    # Process pathways
    puts "loading pathways ..."
    Pathway.delete_all
    IO.readlines(datadir + "resources/msigdb/c2.cp.v3.0.symbols.gmt").each do |l|
      ls = l.chomp.split("\t")
      pw = ls.shift
      url = ls.shift
      mrna_ids = ls.map{|x| mrnas[x] || malias[x]}.compact # mRNA ids
      pway = Pathway.create(:name => pw, :url => url)
      pway.mrnas = Mrna.where(:id => mrna_ids)
      pway.save
    end
    puts "stored #{Pathway.count} pathways"
    
    # Process target interactions
    puts "reading target interactions ..."
    targets = Hash.new() {|h,k| h[k] = Array.new(3,'\N')}
    # order is important here(!), has to match order of fields in table
    ['mirsvr','targetscan_pct','targetscan_contextscore'].each_with_index do |tdir,idx|
      Dir.glob(datadir + "targets/#{tdir}/hsa-*.tsv").each do |mirf|
        mirn = mirf.chomp.split("/")[-1][0..-5]
        next if !mirnas.key?(mirn)
        mir = mirnas[mirn]
        IO.readlines(mirf).each do |l|
          ls = l.chomp.split("\t")
          mrna = mrnas[ls[0]] || malias[ls[0]]
          next if mrna.nil?
          targets[mir.to_s+":"+mrna.to_s][idx] = ls[1].to_f
        end
      end
    end
        
    puts "Stored #{targets.size} target interactions"
#    puts "lin28"
#    pp targets[mirnas['hsa-let-7b'].to_s+":"+mrnas['LIN28B'].to_s]
    
    # Process cross association scores
    puts "loading cross association scores ..."
    CrossAssociationScore.delete_all

    mirs = Dir.glob(datadir+"correlations/cross/hsa-*.tsv")
    pbar = ProgressBar.new('cross',mirs.size)
    tmp_data = []
    of = File.open("tmp/cross.tsv",'w')
    mirs.each do |mirf|
      pbar.inc
      mir = mirf.chomp.split("/")[-1][0..-5]
      mirna = mirnas[mir] or next
      # hash to avoid duplicates in rare cases
      # with strange ambigious alias mappings
      processed_mrnas = Hash.new 
      # we sort mirna lines by gene id to make sure we are getting the same gene
      # for ambigious alias mappings
      IO.readlines(mirf).sort[0..num_associations].each do |l|
        ls = l.chomp.split("\t")
        mrna = mrnas[ls[0]] || malias[ls[0]]

        if mrna.nil?
          puts "Error: mRNA #{ls[0]} does not exist ..."
          next
        end

        next if processed_mrnas.key?(mrna)
        
        score = ls[1].to_f
        fdr = ls[3].to_f
        rnks = ls[4]
        regr_scores = ls[5]
        # compute relative ranks, remember rnks are alway relative to
        # direction/sign of AR score
        # if AR score > 0, ranks are relative to a descending list
        # and we want AR score < 0 to be 0, AR > 0 to be 1
        # and some ranks may be NA
        relranks = rnks.split(",").zip(ngenes_pr_ctype[mir]).map{|x,n| x == 'NA' ? 'NA' : (score > 0 ? (n.to_f-x.to_f)/n.to_f - 1/(2*n.to_f) : x.to_f/n.to_f - 1/(2*n.to_f))}.map{|x| x == 'NA' ? 'NA' : sprintf("%.5f", x)}.join(",")
        # targets
        ts = targets[mirna.to_s+":"+mrna.to_s]
        #pp ts if mrna == 13841 and mirna == 2
        # add a binary target indicator 0/1 if mirsvr or tscan site
        is_target = ((ts[0].to_f.abs > 0 or ts[2].to_f.abs > 0) ? 1 : 0)
        #pp ts if mrna == 13841 and mirna == 2
        
        #  as = [ls[1].to_f, rnks, relranks] + ts + [mrna, mirna] # foreign keys are last
        # we can define cross_id by mrna_id*1000+mirna_id
        as = [mrna*1000+mirna, score, fdr, rnks, relranks, regr_scores] + ts + [is_target, mrna, mirna] # foreign keys are last
        #pp as if mrna == 13841 and mirna == 2

        of.puts as.join("\t")

        processed_mrnas[mrna] = 1        
      end
    end
    pbar.finish
    of.close

    #puts "importing data ..."
    #dbidx = 0 # db index
    #File.open("tmp/cross.tsv",'w') do |of|
    #  tmp_data.each do |x|
        #dbidx +=1;
        #of.puts ([dbidx]+x).join("|")
    #    of.puts x.join("|")
    #  end
    #end
    #Kernel.system("sqlite3 db/#{db}.sqlite3 '.import tmp/cross.tsv cross_association_scores'")
    Kernel.system("psql -d dev -c \"copy cross_association_scores from '#{Rails.root}/tmp/cross.tsv'\"")
    #File.delete("tmp/cross.tsv")
    
    # Process association scores
    puts "loading association scores ..."
    AssociationScore.delete_all
    dirs = Dir.glob(datadir+'correlations/*').select{|f| File.directory?(f) and f.split("/")[-1] != 'cross'}
    dbidx = 0 # db index
    dirs.each do |cdir|
      ctypen = cdir.split("/")[-1].upcase
      ctype = ctypes[ctypen]
      mirs = Dir.glob("#{cdir}/hsa-*.tsv")
      pbar = ProgressBar.new(ctypen,mirs.size)
      tmp_data = []
      mirs.each do |mirf|
        pbar.inc
        mir = mirf.chomp.split("/")[-1][0..-5]
        mirna = mirnas[mir] or next

        # hash to avoid duplicates in rare cases
        # with strange ambigious alias mappings
        processed_mrnas = Hash.new 
        # we sort mirna lines by gene id to make sure we are getting the same gene
        # for ambigious alias mappings
        
        IO.readlines(mirf).sort.each do |l|
          ls = l.chomp.split("\t")

          regr_score = ls[1].to_f
          next if regr_score.abs < 2
          
          mrna = mrnas[ls[0]] || malias[ls[0]]
          if mrna.nil?
            #puts "Error: mRNA #{ls[0]} does not exist ..."
            next
          end

          next if processed_mrnas.key?(mrna)
          
          # this is slow ... but works
          #cross = CrossAssociationScore.where("mirna_id = ? and mrna_id = ?",mirna,mrna).first
          #next if cross.nil?
          #cross_id = cross.id

          # we can define cross_id by mrna_id*1000+mirna_id
          cross_id = mrna*1000+mirna
          
          tmp_data << [regr_score,ctype,cross_id]
          processed_mrnas[mrna] = 1
        end
      end
      pbar.finish
      puts "writing tmp data file ..."
      File.open("tmp/#{ctypen}.tsv",'w') do |of|
        tmp_data.each do |x|
          dbidx +=1;
          #of.puts ([dbidx]+x).join("|")
          of.puts ([dbidx]+x).join("\t")
        end
      end
      puts "importing data ..."
      #Kernel.system("sqlite3 db/#{db}.sqlite3 '.import tmp/#{ctypen}.tsv association_scores'")
      Kernel.system("psql -d dev -c \"copy association_scores from '#{Rails.root}/tmp/#{ctypen}.tsv'\"")
      File.delete("tmp/#{ctypen}.tsv")
    end
        
    # done ...
    
    puts "miRNAs ..."
    puts  Mirna.count
    puts "mRNAs ..."
    puts  Mrna.count
    puts "mRNA alias ..."
    puts  MrnaAlias.count
    puts "Pathways ..."
    puts  Pathway.count
    puts "Cancer types ..."
    puts  CancerType.count
    puts "Association scores ..."
    puts  AssociationScore.count
    puts "Cross association scores ..."
    puts  CrossAssociationScore.count
    
  end
    
  desc 'Load development data snapshot.'
  task :load_test do
    # only load first 20 associations for each miRNA
    load_data(20-1,'development')    
  end

  desc 'Load production data'
  task :load_all do
      # load all data
      load_data(-1,'development')
  end

end
