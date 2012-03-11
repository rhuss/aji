define(["text!tmpl/mbeanSidebar.html","underscore","jquery","aji/JolokiaClient","domReady!"],(text,_,$,jolokia) ->

  ITEM = '<li><a href="#"></a></li>'
  DOMAIN_LIST = '<ul></ul>'
  MBEAN_LIST = '<ul></ul>'

  class MBeanNavigator

    constructor: (@element) ->
      @$element = $(element)

      $div = $("<div class='well'></div>").appendTo(@$element)
      @$textField = $("<input type='text'></input>").appendTo($div)

      mbeans = jolokia.mBeans();
      $ul = $(DOMAIN_LIST).appendTo($div)

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

      $ul.html(domains)


  MBeanNavigator
#      templ = _.template(text)
#      console.log(templ)
#      mbeans = jolokia.mBeans()
#      console.log(mbeans)
#      $(".sidebar").append($(templ(
#          mbeans: mbeans
#      )))
)