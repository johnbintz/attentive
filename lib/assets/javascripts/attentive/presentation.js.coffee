if !Attentive? then Attentive = {}

class Attentive.Presentation
  @setup: (identifier) ->
    starter = ->
      setTimeout(
        ->
          (new Attentive.Presentation(identifier)).start()
        , 250
      )
    window.addEventListener('DOMContentLoaded', starter, false)

  constructor: (@identifier) ->
    @length = @allSlides().length
    @priorSlide = null
    @initialRender = true

    @timer = new Attentive.PresentationTimer()
    @timer.hide()

    @currentWindowHeight = null

    document.querySelector('body').appendChild(@timer.el)

  bodyClassList: ->
    @_bodyClassList ||= document.querySelector('body').classList

  allSlides: ->
    @_allSlides ||= Attentive.Slide.fromList(@slidesViewer().querySelectorAll('.slide'))

  slidesViewer: ->
    @_slidesViewer ||= document.querySelector(@identifier)

  start: ->
    @timer.render()

    document.addEventListener('keydown', @handleKeyDown, false)
    document.addEventListener('mousedown', @handleMouseDown, false)
    document.addEventListener('mouseup', @handleMouseUp, false)
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
    Number(location.hash.substr(1))

  handlePopState: (e) =>
    this.advanceTo(this.slideFromLocation())

  handleMouseDown: (e) =>
    @startSwipeX = e.x

  handleMouseUp: (e) =>
    distance = @startSwipeX - e.x
    if Math.abs(distance) > 10
      if distance < 0
        this.advance(-1)
      else
        this.advance(1)
    else
      this.advance() if e.target.tagName != 'A'

  handleKeyDown: (e) =>
    switch e.keyCode
      when 72
        this.advanceTo(0)
      when 37, 33
        this.advance(-1)
      when 39, 32, 34
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

  advanceTo: (index) =>
    @priorSlide = @currentSlide
    @currentSlide = index || 0

    this.calculate()

    location.hash = @currentSlide

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
