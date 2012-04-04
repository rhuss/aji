define(["backbone","aji/mbean/NavigatorView","aji/mbean/MBeanView"],(Backbone,NavigatorView,MBeanView) ->

  MBeanBrowserView = Backbone.View.extend(

    tagName: "div"

    attributes:
      "class": "row-fluid"

    initialize: () ->
        @$el.append(new NavigatorView().render({hide: true}).el)
        @$el.append(new MBeanView().el)
  )

)