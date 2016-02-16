Ají
===

> Ají is [Jolokia][1] UI which contains a Dashboard with various textual
> and graphical widgets and an MBean Browser for an easy exploration of
> the JMX space. It is an add-on to the normal Jolokia agents and gets
> deployed along with it.

Well, this is how it will look like. At the moment there is not much
here and we are still in the design phase. In this README you will
find a description of the planned tech stack, description of the use
cases to be implemented, a rough roadmap and some ideas for future
versions. And how you can participate:

## Join Us!

This project is open. Since there is not much yet here, so it is a
good chance to dig into. The only requirement is a decent knowledge of
Javascript (which goes beyond spicing up web sites). We start with
[Fork + Pull Model](http://help.github.com/pull-requests/)
and will continue to a mixed _Fork + Pull_ / _Shared Repository Model_
where a small team will do the integration in the shared repository. 

Development is coordinated over two channels:

* A mailing-list
  [aji-dev@googlegroups.com](mailto:aji-dev@googlegroups.com). Please
  use [Google Groups](https://groups.google.com/forum/#!forum/aji-dev)
  for subscribing. 
* A scrum based task distribution with help of
  [Ají's JIRA](https://jolokia.jira.com/browse/AJI). The
  current planned stories and task can be found in the
  planning board.
* Use IRC channel `#jolokia` for live discussions on
  [Freenode](http://freenode.net/)

## High Level Design Goals

This list of a high level goals serve as guideline for the overall
development. These are not connected to a particular use case, but
always part of the acceptance criteria of each user story

* *Self contained* - it is essential, that Ají gets deployed along
   with the Jolokia agent it uses as backend. This implies that there
   will be 4 variants, each for each Jolokia agent variant. 
* *Small* - Ají + Jolokia <= 350k.
* *Fast* - The performance of Ají depends on various factors like the
   client side javascript execution or the number of server side
   interaction. Performance tests should backup performance thresholds.
* *Good UX* - A focus should be on keyboard navigation, appropriate
   (and maybe innovative) UI elements and an overall good user
   experience. Difficult.
* *Beautiful* - it should look good. This means there should be put
   efforts into the choice of things like fonts, spacing, UI element
   arrangements, fluid behaviour.

## Use Cases

The first two use cases we want to cover is a _Dashboard_ and a
_MBean Browser_.

### Dashboard

The _Dashboard_ provides timeseries chart and other widget which can
be grouped in various sections. There are widget that came out of the
box (Memory usage, thread count), application server specific widgets
and others can be defined by the user. The user can arrange the
widgets freely on the dashboard and the configuration is saved locally
in the browser

![Ají Dashboard](https://jolokia.jira.com/secure/attachment/10114/dashboard1.png)

See [AJI-3](https://jolokia.jira.com/browse/AJI-3) for details. 

### MBean Browser

The _MBean Browser_ allows for easy navigation to an MBean and
applying certain actions like reading/writing of attributes or
execution of operations. Keyboard navigation is easily possible. 

See [AJI-1](https://jolokia.jira.com/browse/AJI-1) for details.

### Additional Ideas

* Plugin architecture
* Development Tools 
  - Thread Dump Analysis
  - Memory Analysis
* App-Server specific views

## Tech Stack

Ají is also a playground project for having fun with the latest stuff,
even when it is not matured. That's our fun part ;-). Also, browser
compatibility is not a main goal and Ají will require decent HTML-5
capabilities.

Armed with this freedom, and after quite some time of research and
evaluation the following tech stack settled won, although nothing is
really fixed while we are going.

As already said, Ají will be a SPA (_single page application_) with
no logic on the server side and everything running on the client. The
Jolikia agent is the server part (with maybe some slight addition for
supporting some use cases). 

Here now the proposed stack. It is not really settled down, maybe you
have some strong opinions here ? Let us know at
`aji-dev@googlegroups.com`.

### Coffeescript

I tried it and I like it. My only concerns where about an extended
round-trip due to the extra compilation step and debugging hurdles for
correlating back to the CS source. The former can be avoided by a
proper build process and workflow (see below), the later is
(currently) a non-issue since it is really straightforward from the
generated JS code to the original CS code. 

### Build system

A build system has to be *really* important to carefully be chosen
since it completely dominates the development workflow and overall
development experience. I considered [Gradle](http://www.gradle.org),
but this was really to different from my old love-hate, Maven. I
feel to uncoformtable to make the switch now (although I will try
graddle sometimes), especially since, I found a Maven setup for a
development workflow without an explicite build step: Save
CoffeeScript source (or let it automatically save by a decent IDE),
reload browser. This works even over module and project boundaries
(e.g. the Jolokia javascript sources can used the same way although
sitting in a completely different project).

An initial example is checked in:

   $ cd aji/war
   $ mvn jetty:run
   .....
   [other terminal:]
   $ cd aji/war
   $ mvn brew:compile -Dbrew.watch=true
   .....
   [other terminal:]
   $ vi aji/war/src/main/coffeescript/aji/jolokia.coffee
   [edit and save]
   [watch output on terminals]
   [reload http://localhost:8080/aji/app/index.html or so]

The main ingredients are a Maven [Jetty Plugin](http://docs.codehaus.org/display/JETTY/Maven+Jetty+Plugin) with customized
`contextHandler` configuration an the [Brew Plugin](https://github.com/jakewins/brew) for compiling
Cofeescript source. The later includes also a watch mode for
periodically checking the CoffeeScript source. 

### MVC Platform

Several JS MVC platform has been checked briefly (see this
[overview](http://codebrief.com/2012/01/the-top-10-javascript-mvc-frameworks-reviewed/)
for a summary) and the current favourite is still
[backbone.js](http://documentcloud.github.com/backbone/) for the
following reasons:

* Seems to have the largest momemtum
* Small enough
* Sufficient for our needs

An alternative would be [spine.js](http://spinejs.com/).

Whether Ají requires an additional layer as application framework on top of backbone.js has not
yet been evaluated:
[Thorax](http://functionsource.com/post/lumbar-support-for-your-thorax-introducing-an-opinionated-backbone-application-framework),
[Marionette](http://derickbailey.github.com/backbone.marionette) and
[Chaplin](https://github.com/moviepilot/chaplin). On a first view,
Chaplin seems to be quite charming.

### Module Management

Something really missing out of the box for (the current) Javascript
is a module system like for other languages. This lack really made me
the largest headache coming from an non Javascript background used to
work with cool systems like OSGi. But happily there are solutions. For
the browser [RequireJS](http://requirejs.org/) is the de facto
[AMD](https://github.com/amdjs/amdjs-api/wiki/AMD) loader. However,
the tendency at the moment goes to
[curl.js](https://github.com/cujojs/curl) because it seems to be quite
smaller, it is supossed to be faster and has a very nice
API. Although, there is some ecosystem around it (_cujo_) which could
be helpful as well.

### Layout and UI

Everybody uses [Bootstrap](http://twitter.github.com/bootstrap/) these
days, there even already quite some
[additions](http://www.webresourcesdepot.com/20-beautiful-resources-that-complement-twitter-bootstrap)
to the hype. Since I'm not a design expert (although I highly
appreciate good design), we will go this road as well with appropriate
adoption (there must be a chili somewhere ;-). This implies that we
will use [Less](http://lesscss.org/) as well, which a good thing on
its own. 

### Charting

There are tons of charting libraries out there. However, most of them
have memory issues if the charts are updated periodically (which is
the common use case for us). That is the major reason, why Tomasz
Nurkiewicz has chosen [Highcharts](http://www.highcharts.com/) as charting library for its
[Jolokia Dashboard Sample](http://nurkiewicz.blogspot.com/2011/03/jolokia-highcharts-jmx-for-human-beings.html). However,
HighCharts is not free and not compatible to an Apache License, so
that it is not suitable for our purposes where we have to package and
distribute the charting library along with the agent.

Another nice approach for modern browsers is to use SVG based charting
(instead of canvas based one). Here,
[d3.js](http://mbostock.github.com/d3/) is an outstanding support
library, however it is rather low-level.

In order to let the door open for various graphing library some sort
of abstraction bei an plugin API would be nice as described
[here](http://bost.ocks.org/mike/chart/) 

### Local storage / IndexedDB

Since server side persistence is not yet in focus, for persistence
needs like the dashboard configuration HTML-5 client side storage
should be used. The first option should be [IndexedDB](https://developer.mozilla.org/en/IndexedDB) with an
fallback to [LocalStorage](http://dev.w3.org/html5/webstorage/) and cookies. Why IndexedDB should be the
first choice is laid out in this
[post](http://paul.kinlan.me/we-need-to-kill-off-the-localstorage-api)
whose arguments I can follow. 


  [1]: http://www.jolokia.org
