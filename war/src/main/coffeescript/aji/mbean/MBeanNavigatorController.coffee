define(["backbone","jquery","aji/mbean/MBeanNavigatorModel","aji/mbean/MBeanNavigatorView","domReady!"],(Backbone,$,MBeanNavigatorModel,MBeanNavigatorView) ->

  MBeanNavigatorController = Backbone.Router.extend(
    initialize: ->
      model = new MBeanNavigatorModel()
      new MBeanNavigatorView(
          model: model
          el: $(".sidebar")
      )
  )

  MBeanNavigatorController
)