define(["backbone","underscore","jquery","aji/mediator","aji/jolokia","aji/TemplateManager"],(Backbone,_,$,mediator,jolokia,TemplateManager) ->

  compositeDataHandler = (attr,value,meta) ->
    TemplateManager.template("compositeData",
        data: for key,val of value
           {
              key: key
              value: val
           }
    )

  tabularDataHandler = (attr,value,meta) ->
    console.dir(value)
    value

  # ========================================= View definition

  MBeanView = Backbone.View.extend(

    attributes:
      class: "span9"

    initialize: ->
      mediator.subscribe("navigator-mbean-select",(mbean) => @render(mbean))

    typeHandler:
      'java.lang.String':
         name: 'String'
      'javax.management.openmbean.CompositeData':
         name: 'CompositeData'
         handler: compositeDataHandler
      'javax.management.openmbean.TabularData':
         name: 'TabularData'
         handler: compositeDataHandler

    arrayRegexp: /^\s*\[L(.*);\s*$/

    render: (mbean) ->
      # add up a map
      info = jolokia.getMBeanInfo(mbean)
      attributeValues = jolokia.j4p.getAttribute(mbean,undefined,{ignoreErrors: true})
      attributes = info["attr"]
      console.dir(attributes)
      data = for attr,meta of attributes
        { name: attr
        desc: @cleanupDescription(attr,meta)
        value:@prepareValue(attr,attributeValues[attr],meta)
        type: @shortenType(meta.type)
        rw: meta.rw }

      html = TemplateManager.template("attributes",
        data: data
        info: info
        attributes: attributes
      )
      @$el.html(html)
      #@$el.text("Info: " + JSON.stringify(info))

    shortenType: (type) ->
      arrayMatch = @arrayRegexp.exec(type);
      isArray = false
      if (arrayMatch)
        type = arrayMatch[1]
        isArray = true
      type = @typeHandler[type]?.name || type
      type += "[]" if isArray
      type

    cleanupDescription: (name,meta) ->
      return if meta.desc == name then "" else meta.desc

    prepareValue: (attr,value,meta) ->
      handler = @typeHandler[meta.type]?.handler
      if (handler)
        handler(attr,value,meta)
      else
        "<strong>" + value + "</strong>"

  )

)
