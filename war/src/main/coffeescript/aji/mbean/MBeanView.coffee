define(["backbone","underscore","jquery","aji/mediator","aji/jolokia","aji/TemplateManager"],(Backbone,_,$,mediator,jolokia,TemplateManager) ->
  MBeanView = Backbone.View.extend(

    attributes:
      class: "9span"

    initialize: ->
      mediator.subscribe("navigator-mbean-select",(mbean) => @render(mbean))

    render: (mbean) ->
      # add up a map
      info = jolokia.getMBeanInfo(mbean)
      attributeValues = jolokia.j4p.getAttribute(mbean,undefined,{ignoreErrors: true})
      attributes = info["attr"]
      console.dir(attributes)
      data = for attr,meta of attributes
        { name: attr
        desc: meta.desc
        value: attributeValues[attr]
        type: meta.type
        rw: meta.rw }
      console.dir(data)

      html = TemplateManager.template("mbean",
        data: data
        info: info
        attributes: attributes
      )
      @$el.html(html)
      #@$el.text("Info: " + JSON.stringify(info))
  )
)
