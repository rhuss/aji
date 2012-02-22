define(["text!tmpl/mbeanSidebar.html","underscore","jquery","domReady!"],(text,_,$) ->
  $(".sidebar").append($(text))
  templ = _.template(text)

)