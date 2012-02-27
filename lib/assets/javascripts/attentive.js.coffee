#= require underscore
#
class PresentationTimer
  constructor: ->
    @time = 0
    @el = document.createElement('div')
    @el.classList.add('timer')

    this.render()

  render: ->
    @el.innerHTML = this.formattedTime()

  start: ->
    @_runner = this.runner()
    @el.classList.add('running')

  runner: ->
    setTimeout(
      =>
        this.render()
        @time += 1
        this.runner() if @_runner?
      , 1000
    )

  stop: ->
    clearTimeout(@_runner)
    @el.classList.remove('running')
    @_runner = null

  reset: ->
    this.stop()
    @time = 0
    this.render()

  toggle: ->
    if @_runner?
      this.stop()
    else
      this.start()

  toggleVisible: ->
    @el.classList.toggle('hide')

  isVisible: ->
    !@el.classList.contains('hide')

  hide: ->
    @el.classList.add('hide')

  formattedTime: ->
    minute = "00#{Math.floor(@time / 60)}".slice(-2)
    second = "00#{@time % 60}".slice(-2)

    "#{minute}:#{second}"

class Slide
  @fromList: (list) ->
    result = (new Slide(slide) for slide in list)

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

class this.Attentive
  @setup: (identifier) ->
    starter = ->
      setTimeout(
        ->
          (new Attentive(identifier)).start()
        , 250
      )
    window.addEventListener('DOMContentLoaded', starter, false)

  constructor: (@identifier) ->
    @length = @allSlides().length
    @priorSlide = null
    @initialRender = true

    @timer = new PresentationTimer()
    @timer.hide()

    @currentWindowHeight = null

    document.querySelector('body').appendChild(@timer.el)

  bodyClassList: ->
    @_bodyClassList ||= document.querySelector('body').classList

  allSlides: ->
    @_allSlides ||= Slide.fromList(@slidesViewer().querySelectorAll('.slide'))

  slidesViewer: ->
    @_slidesViewer ||= document.querySelector(@identifier)

  start: ->
    if !this.isFile()
      window.addEventListener('popstate', @handlePopState, false)

    document.addEventListener('click', @handleClick, false)
    document.addEventListener('keydown', @handleKeyDown, false)
    window.addEventListener('resize', _.throttle(@calculate, 500), false)

    imageWait = null
    imageWait = =>
      wait = false

      for slide in @allSlides()
        for img in slide.dom.getElementsByTagName('img')
          wait = true if !img.complete

      if wait
        setTimeout(imageWait, 100)
      else
        this.advanceTo(this.slideFromLocation())

    imageWait()

  slideFromLocation: ->
    value = if this.isFile()
      location.hash
    else
      location.pathname

    Number(value.substr(1))

  handlePopState: (e) =>
    this.advanceTo(if e.state then e.state.index else this.slideFromLocation())

  handleClick: (e) =>
    this.advance() if e.target.tagName != 'A'

  handleKeyDown: (e) =>
    switch e.keyCode
      when 72
        this.advanceTo(0)
      when 37
        this.advance(-1)
      when 39, 32
        this.advance()
      when 220
        @timer.reset()
      when 84
        if e.shiftKey
          @timer.toggleVisible()
        else
          @timer.toggle() if @timer.isVisible()

  advance: (offset = 1) =>
    this.advanceTo(Math.max(Math.min(@currentSlide + offset, @length - 1), 0))

  isFile: => location.href.slice(0, 4) == 'file'

  advanceTo: (index) =>
    @priorSlide = @currentSlide
    @currentSlide = index || 0

    this.calculate()

    if this.isFile()
      location.hash = @currentSlide
    else
      history.pushState({ index: @currentSlide }, '', @currentSlide)

  calculate: =>
    if @currentWindowHeight != window.innerHeight
      recalculate = true
      times = 3

      while recalculate and times > 0
        recalculate = false
        times -= 1

        for slide in @allSlides()
          recalculate = true if slide.recalculate()

      @currentWindowHeight = window.innerHeight

      @slidesViewer().style['width'] = "#{window.innerWidth * @allSlides().length}px"

    this.align()

  getCurrentSlide: =>
    @allSlides()[@currentSlide]

  align: =>
    @allSlides()[@priorSlide].deactivate() if @priorSlide
    this.getCurrentSlide().activate()

    @slidesViewer().style['left'] = "-#{@currentSlide * window.innerWidth}px"

    if @initialRender
      @bodyClassList().remove('loading')

      @initialRender = false
      @currentWindowHeight = null
      this.calculate()
