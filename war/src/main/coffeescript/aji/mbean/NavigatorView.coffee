define(["backbone","underscore","jquery","aji/mediator","aji/jolokia","aji/TemplateManager"],(Backbone,_,$,mediator,jolokia,TemplateManager) ->

  ###
   The Navigator view used for handling the MBean navigator for looking up MBeans.
   It publishes the global 'navigator-mbean-select' event when an mbean is seleted.
  ###

  NavigatorView = Backbone.View.extend(

    tagName: "div"

    attributes:
      class: "span3"

    events:
      keypress: "keyPress"
      keydown: "keyDown"
      keyup: "keyUp"

    # Textfield used for filter
    $filterEl: null

    # Outer list
    $ul: null

    domain2ElementMap: {}

    mbean2ElementMap: {}

    filter: ""

    initialize: () ->
      # Create the filter box
      @$filterEl = $(@make("input",
        type: "text"
        class: "search-query filter"
        placeholder: "Filter"
      )).appendTo(@$el)

      @$ul = $("<ul class='nav nav-pills nav-stacked navigator domain-list'></ul>").appendTo(@$el)
      @$ul.delegate("li.navigator","click",@clickHandler)

    render: (opts) ->
      mBeanMap = jolokia.mBeans()
      @$ul.empty()
      for domain,mbeans of mBeanMap
        $domain = $("<li class='navigator domain'></li>").appendTo(@$ul)
        $domain.data(
          domain: domain
        )
        @domain2ElementMap[domain] = $domain
        $domainMenu = $("<a href='#' class='navigator domain-name'><i class='icon-arrow-right'></i>" + domain + "</a>");
        $domain.append($domainMenu)
        $mbeans = $("<ul class='nav nav-pills nav-stacked navigator mbean-list'></ul>").appendTo($domain)
        for mbean in _.keys(mbeans).sort()
          $mbean = $("<li class='navigator mbean'></li>").append($("<a href='#'></a>").text(mbean.replace(/,/g,", "))).appendTo($mbeans)
          objectname = domain + ":" + mbean
          $mbean.data(
            domain: domain
            mbean: objectname
          )
          @mbean2ElementMap[objectname] = $mbean
        $mbeans.hide() if opts?.collapse
      @

    # =====================================================================
    # Keyhandler

    clickHandler: (ev) ->
      selectMBeanOrDomain($(ev.currentTarget))
      ev.stopPropagation()

    keyPress: (ev) ->
      ev.stopPropagation()
      console.log("KC: " + ev.keyCode)
      switch ev.keyCode
        when 38
          @upInList()
          ev.preventDefault()
        when 40 then @downInList()
        when 13 then @selectInList(ev)

    keyDown: (ev) ->
      if ( ($.browser.webkit || $.browser.msie) && ev.keyCode != 13)
        @keyPress(ev)

    keyUp: (ev) ->
      filter = ev.target.value
      if (filter != @filterText)
        @filterText = filter
        @$ul.find('.active').removeClass('active')
        if (!filter.length)
          @$ul.find('li').show().find('ul').hide()
          return
        filterRegexp = new RegExp(filter,"i");
        @$ul.find('li').each( ->
          val = $(this).text()
          console.log(val);
          if filterRegexp.exec(val)
            $(this).parent().show()
            $(this).show()
          else
            $(this).hide()
        )

    downInList: () ->
      $active = @$ul.find('.active').removeClass('active')
      $next = $active.find('li:visible').first()
      if (!$next.length)
        $next = $active.next()
        $next = $next.next() while $next != null && $next.is(":hidden")
        if (!$next.length)
          $next = $active.parents('li:visible').first()
          if ($next.length)
            $next = $next.nextAll('li:visible').first()
          if (!$next.length)
            $next = $(@$ul.find('li:visible')[0])
      $next.addClass("active")

    # If none -> first domain is active
    # Dive into visible domains
    upInList: () ->
      $active = @$ul.find('.active').removeClass('active')
      $prev = $active.prev().find('li:visible').last()
      if (!$prev.length)
        $prev = $active.prev()
        # Lookup previous elements until one none hidden is foundl
        $prev = $prev.prev() while $prev != null && $prev.is(":hidden")
        $visibleChilds = $prev.find("li:visible")
        if ($visibleChilds.length)
          $prev = $visibleChilds.last()
        if (!$prev.length)
          $prev = $active.parents('li:visible').first()
          if (!$prev.length)
            $prev = @$ul.find('li:visible').last()
      $prev.addClass('active')

    selectInList: (ev) ->
      $active = @$ul.find('.active')
      selectMBeanOrDomain($active)

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

  selectMBeanOrDomain = ($el) ->
    if ($el.data("mbean"))
      console.log("MBean: " +  $el.data("mbean"))
      mediator.publish("navigator-mbean-select",$el.data("mbean"))
    else if ($el.data("domain"))
      $el.find("ul").toggle('fast')

  NavigatorView
)