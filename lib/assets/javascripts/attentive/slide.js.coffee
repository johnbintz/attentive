if !Attentive? then Attentive = {}

class Attentive.Slide
  @fromList: (list) ->
    result = (new Attentive.Slide(slide) for slide in list)

  constructor: (@dom) ->

  recalculate: =>
    @dom.style['width'] = "#{window.innerWidth}px"

    currentMarginTop = Number(@dom.style['marginTop'].replace(/[^\d\.]/g, ''))
    height = (window.innerHeight - @dom.querySelector('.content').clientHeight) / 2

    if height != currentMarginTop
      @dom.style['marginTop'] = "#{height}px"
      true

  activate: =>
    @dom.classList.add('active')

  deactivate: =>
    @dom.classList.remove('active')

