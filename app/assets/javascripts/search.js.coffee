# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $(document).tooltip()
  $("#association").buttonset()
  $("#targets").buttonset()
  $("#ctype_sort").buttonset()
  $("#ctype_sig").buttonset()

  $("input[type=submit]").button()

  $("#search_form_submit").submit ->
     $('#search_result').html('')
     $("#search_spinner").spin "large", "black"
     $.get @action, $(this).serialize(), null, "script"
     false

  $(document).on "click", ".pagination a", ->
     $("#paginate_spinner").spin "small", "black"
     $.getScript @href
     false

  $("#miRNA").autocomplete
     source: "/search/mirnas",
     minLength: 2

#  $("#GBM_radio").click ->
#     alet "click!"
#     $("#GBM_sig_check").button.enable() if $("#GBM_radio").button("option","enabled");
#     $("#GBM_sig_check").button.disable() if $("#GBM_radio").button("option","disabled");

  $("#miRNA").click ->
    $(this).val "" if $(this).val() is "miRNA"

  $("#miRNA").blur ->
    $(this).val "miRNA" if $(this).val() is ""

  $("#mRNA").autocomplete
     source: "/search/mrnas",
     minLength: 2

  $("#mRNA").click ->
    $(this).val "" if $(this).val() is "mRNA"

  $("#mRNA").blur ->
    $(this).val "mRNA" if $(this).val() is ""

  $("#pathway").autocomplete
     source: "/search/pathways",
     minLength: 3

  $("#pathway").click ->
    $(this).val "" if $(this).val() is "gene set / pathway"

  $("#pathway").blur ->
    $(this).val "gene set / pathway" if $(this).val() is ""

  $("#geneset").autocomplete
     source: "/search/mrnas",
     minLength: 2

  $("#geneset").click ->
     $(this).val ""

#  $.fn.sparkline.defaults.bar.barWidth = 8
#  $.fn.sparkline.defaults.bar.barSpacing = 2
#  $.fn.sparkline.defaults.bar.nullColor = "white"
#  $.fn.sparkline.defaults.bar.tooltipFormat = "<span style=\"color: {{color}}\">&#9679;</span> {{value:names}}</span>"
  $.fn.sparkline.defaults.common.height = "25px"
  $.fn.sparkline.defaults.common.chartRangeMin = -0.5  
  $.fn.sparkline.defaults.common.chartRangeMax = 0.5

# $.fn.sparkline.defaults.bar.colorMap = $('#dtc').data('ccolors')

updateSparkline = ->
     for field in $('.barplot')
       dt = $(field).data('ranks')
       vals = ((if f.rr == -10 then null else f.rr-0.5) for f in dt)
       nms = {}
       nms[f.rr-0.5] = "#{f.name} : rank #{if !f.rank? then 'NA' else f.rank}" for f in dt
       $(field).sparkline vals,
         type: 'bar'
         colorMap: $('#dtc').data('ccolors')
         barWidth: 8
         barSpacing: 2
         nullColor: "grey"
         tooltipFormat: "<span style=\"color: {{color}}\">&#9679;</span> {{value:names}}</span>"
         tooltipValueLookups: {names: nms}
     for field in $('.barplot_targets')
       dt = $(field).data('targets')
       vals = (f.val for f in dt)
       nms = {}
       nms[f.val] = "#{f.method} : #{if f.score == 0 then '0' else f.score}" for f in dt
       $(field).sparkline vals,
         type: 'bar'
         colorMap: ['#555','#555','#555']
         barWidth: 8
         barSpacing: 2
         height: "25px"
         nullColor: "white"
         chartRangeMin: 0.0
         chartRangeMax: 1.5
         tooltipFormat: "<span style=\"color: {{color}}\">&#9679;</span> {{value:names}}</span>"
         tooltipValueLookups: {names: nms}

$(document).ready ->
   updateSparkline()

$(document).ajaxComplete (event, xhr, settings) ->
   return if settings.url.indexOf("/search/pairs?") == -1
   updateSparkline()
