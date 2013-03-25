# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121102153151) do

  create_table "association_scores", :force => true do |t|
    t.float   "score_regr"
    t.integer "cancer_type_id"
    t.integer "cross_association_score_id"
  end

  add_index "association_scores", ["cancer_type_id"], :name => "as_ctype"
  add_index "association_scores", ["cross_association_score_id"], :name => "as_cas_id"
  add_index "association_scores", ["score_regr"], :name => "as_score"

  create_table "cancer_types", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.integer "sample_count"
    t.string  "color"
  end

  add_index "cancer_types", ["name"], :name => "index_cancer_types_on_name", :unique => true

  create_table "cross_association_scores", :force => true do |t|
    t.float   "score"
    t.float   "fdr"
    t.string  "ranks"
    t.string  "relative_ranks"
    t.string  "regr_scores"
    t.float   "target_mirsvr"
    t.float   "target_tscan_pct"
    t.float   "target_tscan_contextscore"
    t.boolean "is_target"
    t.integer "mrna_id"
    t.integer "mirna_id"
  end

  add_index "cross_association_scores", ["is_target"], :name => "cas_target"
  add_index "cross_association_scores", ["mirna_id"], :name => "cas_mirna"
  add_index "cross_association_scores", ["mrna_id"], :name => "cas_mrna"
  add_index "cross_association_scores", ["score"], :name => "cas_score"

  create_table "mirnas", :force => true do |t|
    t.string "name"
  end

  add_index "mirnas", ["name"], :name => "index_mirnas_on_name", :unique => true

  create_table "mrna_aliases", :force => true do |t|
    t.string  "alias"
    t.integer "mrna_id"
  end

  add_index "mrna_aliases", ["alias"], :name => "index_mrna_aliases_on_alias"

  create_table "mrnas", :force => true do |t|
    t.string "symbol"
    t.string "name"
  end

  add_index "mrnas", ["symbol"], :name => "index_mrnas_on_symbol", :unique => true

  create_table "mrnas_pathways", :id => false, :force => true do |t|
    t.integer "mrna_id"
    t.integer "pathway_id"
  end

  add_index "mrnas_pathways", ["mrna_id", "pathway_id"], :name => "index_mrnas_pathways_on_mrna_id_and_pathway_id", :unique => true
  add_index "mrnas_pathways", ["pathway_id"], :name => "index_mrnas_pathways_on_pathway_id"

  create_table "pathways", :force => true do |t|
    t.string "name"
    t.string "url"
  end

  add_index "pathways", ["name"], :name => "index_pathways_on_name", :unique => true

end
