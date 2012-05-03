###
 Copyright 2012 Roland Huss

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
###


###
 The current implementation uses handelbars template, but can be switched later
 on to something more sophisticated
###
define(["jquery","handlebars"], ($,Handlebars) ->
  Handlebars.registerHelper('eachProp', (context, options) ->
    ret = ""
    for prop,value of context
      ret = ret + options.fn(
          prop:   prop
          value:  value
      )
    ret
  )

  Handlebars.registerHelper('jsonify', (context,options) ->
    JSON.stringify(options.fn(context))
  )

  {
      # Hash of preloaded templates for the app
      templates:{}

      # Recursively pre-load all the templates for the app.
      # This implementation should be changed in a production environment. All the template files should be
      # concatenated in a single file.
      loadTemplates: (names, callback) ->
        loadTemplate = (index) =>
            name = names[index]
            console.log('Loading template: ' + name)
            $.get('tmpl/' + name + '.html', (data) =>
                $sub = $(data).filter("script[type=text/handlebar]")
                if (!$sub.size())
                   @templates[name] = Handlebars.compile(data)
                else
                   tmpl = @templates
                   $sub.each((el) ->
                     tmpl[this.id] = Handlebars.compile($(this).html())
                   )
                index++
                if (index < names.length)
                  loadTemplate(index)
                else
                  callback()
            )
        loadTemplate(0)

      # Get template by name from hash of preloaded templates
      template: (name,context) -> @templates[name](context)
  }
)