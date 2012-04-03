define(["backbone","underscore","aji/jolokia"],(Backbone,_,jolokia) ->

  DomainModel = Backbone.Model.extend(

  )

  MBeanModel = Backbone.Model.extend(

  )

  # Model holding the navigation tree and the currently selected MBean and domain
  NavigatorModel = Backbone.Model.extend(
    initialize: () -> @updateMBeans()

    updateMBeans: () ->
      mBeanMap = jolokia.mBeans()
      @set("mBeanMap",mBeanMap)
      @set("domains",new DomainModel(
        name: domain
        visible: true
        mbeans: (new MBeanModel(
            objectName: domain + ":" + mbean
            name: mbean
            visible: true
          ) for mbean in _.keys(mbeans).sort())
      ) for domain,mbeans of mBeanMap)
      @
  )
  NavigatorModel
)

