define(["backbone","underscore","aji/jolokia"],(Backbone,_,jolokia) ->

  # Model holding the navigation tree and the currently selected MBean and domain
  NavigatorModel = Backbone.Model.extend(
    initialize: () -> @updateMBeans()

    updateMBeans: () ->
      mBeanMap = jolokia.mBeans()
      @set("mBeanMap",mBeanMap)
  )
  NavigatorModel
)

