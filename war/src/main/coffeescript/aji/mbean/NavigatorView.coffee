define(["backbone","underscore","jquery","aji/mediator","aji/mbean/NavigatorModel","aji/TemplateManager"],(Backbone,_,$,mediator,NavigatorModel,TemplateManager) ->

  DomainView = Backbone.View.extend(
    tagName: "li"
    className: "navigator-domain"

    events:
      "click .navigator-domain-toggle": "toggleDomain"

    toggleDomain: (ev) ->
      @toggleMBeans(ev)
      ev.stopPropagation()
      ev.preventDefault()

    render: (opts) ->
      @$el.empty()
      @$el.append(makeLink('navigator-domain-toggle',@model.get("name")))
      @$ul = $(@make("ul")).appendTo(@$el)
      @$ul.append(new MBeanView(
        model: model
      ).render().el) for model in @model.get("mbeans") when model.get("visible")
      @$ul.hide() if opts?.hide
      @

    toggleMBeans: (ev) ->
      @collapsed = !@collapsed
      @$ul.toggle('fast')

  )

  MBeanView = Backbone.View.extend(
    tagName: "li"
    className: "navigator-mbean"

    events:
      "click .navigator-mbean-select": "mbeanSelected"

    render: () ->
      @$el.append(makeLink("navigator-mbean-select",@model.get("name")))
      @$el.data("mbean",@model.get("mbean"))
      @

    mbeanSelected: () ->
      mediator.publish("navigator-mbean-select",@model)
      console.log("MBean: " + @model.get("objectName"));
  )

  NavigatorView = Backbone.View.extend(

    tagName: "ul"

    events:
      "keypress": "keyPress"
      "keydown": "keyDown"

    # Textfield used for filter
    $filter: null

    initialize: () ->
      # Create the filter box
      @$filterEl = $(@make("input",
        type: "text"
        class: "filter"
      )).appendTo(@$el)
      @model = new NavigatorModel();
      mediator.subscribe("navigator-mbean-select",(model) ->
        console.log("Model: " + model.get("objectName"))
      )

    render: (opts) ->
      domains = @model.get("domains")
      @$el.empty();
      @$el.append(@$filterEl)
      @domainViews = []
      for domain in domains when domain.get("visible")
        domainView = new DomainView(
            model: domain
        )
        @domainViews.push(domainView)
        @$el.append(domainView.render(opts).el)
      @

    # =====================================================================
    # Keyhandler

    keyPress: (ev) ->
      ev.stopPropagation()
      switch ev.keyCode
        when 38 then @upInList()
        when 40 then @downInList()

    keyDown: (ev) ->
      if ($.browser.webkit || $.browser.msie)
          @keyPress(ev)

    downInList: () ->
      # Get active element
      handled = false;
      if (activeDomainView)
        handled = activeDomainView.activeNext()
      active = @$list.find('.active').removeClass('active')
      next = active.next()
      if (!next.length)
        next = $(@$list.find('li:visible')[0])
      next.addClass("active")

    # If none -> first domain is active
    # Dive into visible domains
    upInList: () ->
      active = @$list.find('.active').removeClass('active')
      prev = active.prev()

      if (!prev.length)
        prev = @$list.find('li:visible').last()

      prev.addClass('active')
  )

  # ===========================================================================
  # private methods

  # Key handling
  addKeyListener = (nav,$input) ->
    $input.on('keypress', (ev) -> keyPress(nav,ev))

  makeLink = (clazz,value) ->
    $("<a></a>").attr(
        class: clazz
        href: "#"
    ).html(value)

  NavigatorView



#      templ = _.template(text)
#      console.log(templ)
#      mbeans = jolokia.mBeans()
#      console.log(mbeans)
#      $(".sidebar").append($(templ(
#          mbeans: mbeans
#      )))
)