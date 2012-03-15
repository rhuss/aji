define(["text!tmpl/mbeanSidebar.html","underscore","jquery","aji/JolokiaClient","domReady!"],(text,_,$,jolokia) ->

  ITEM = '<li><a href="#"></a></li>'
  DOMAIN_LIST = '<ul></ul>'
  MBEAN_LIST = '<ul></ul>'

  class MBeanNavigator

    # Currently selected domain name
    $selectedDomain: null

    # Currently selected MBean name
    $selectedMBean: null

    # Element to add this navigator to
    $element: null

    # Textfield used for filter
    $filter: null

    constructor: (@element) ->
      @$element = $(element)

      $div = $("<div class='well'></div>").appendTo(@$element)
      @$filter = $("<input type='text'></input>").appendTo($div)
      addKeyListener(this,@$filter)

      mbeans = jolokia.mBeans();
      @$list = $(DOMAIN_LIST).appendTo($div)

      # List of domains
      domains = _.map(_.keys(mbeans).sort(),(domain) =>

        # List of names
        names = _.map(_.keys(mbeans[domain]).sort(),(mbean) =>
          $name = $(ITEM)
          $name.find('a').html(mbean)
          $name[0]
        )

        $mbeanList = $(MBEAN_LIST).html(names).hide()

        $domain = $(ITEM)
        $domain.find('a').html(domain).click((ev) =>
              $mbeanList.toggle('fast')
              ev.stopPropagation()
              ev.preventDefault()
        )

        $domain.append($mbeanList)
        $domain[0]
      )

#      $(domains[0]).addClass('active')
      @$list.html(domains)


  # ===========================================================================
  # private methods

  # Key handling
  addKeyListener = (nav,$input) ->
    $input.on('keypress', (ev) -> keyPress(nav,ev))
    if ($.browser.webkit || $.browser.msie)
      $input.on('keydown', (ev) => keyPress(nav,ev))

  keyPress = (nav,ev) ->
    ev.stopPropagation()
    switch ev.keyCode
      when 38 then upInList(nav)
      when 40 then downInList(nav)

  downInList = (nav) ->
    # Get active element
    active = nav.$list.find('.active').removeClass('active')
    next = active.next()
    if (!next.length)
      next = $(nav.$list.find('li:visible')[0])
    next.addClass("active")
    # If none -> first domain is active
    # Dive into visible domains

  upInList = (nav) ->
    active = nav.$list.find('.active').removeClass('active')
    prev = active.prev()

    if (!prev.length)
      prev = nav.$list.find('li:visible').last()

    prev.addClass('active')


  MBeanNavigator
#      templ = _.template(text)
#      console.log(templ)
#      mbeans = jolokia.mBeans()
#      console.log(mbeans)
#      $(".sidebar").append($(templ(
#          mbeans: mbeans
#      )))
)