define(["backbone","underscore","jquery","aji/mediator","aji/jolokia","aji/TemplateManager"],(Backbone,_,$,mediator,jolokia,TemplateManager) ->
  MBeanView = Backbone.View.extend(

    initialize: ->
      mediator.subscribe("navigator-mbean-select",(mbean) => @render(mbean))

    render: (mbean) ->
      html = TemplateManager.template("mbean",
        info: jolokia.getMBeanInfo(mbean)
        attributes: jolokia.j4p.getAttribute(mbean,undefined,{ignoreErrors: true})
      )
      @$el.html(html)
      #@$el.text("Info: " + JSON.stringify(info))
  )
)
