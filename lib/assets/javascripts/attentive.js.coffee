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

class this.Attentive
  @setup: (identifier) ->
    starter = -> (new Attentive(identifier)).start()
    window.addEventListener('DOMContentLoaded', starter, false)

  constructor: (@identifier) ->
    @length = @allSlides().length
    @priorSlide = null
    @initialRender = true

    @timer = new PresentationTimer()
    @timer.hide()

    document.querySelector('body').appendChild(@timer.el)

  bodyClassList: ->
    @_bodyClassList ||= document.querySelector('body').classList

  allSlides: ->
    @_allSlides ||= @slidesViewer().querySelectorAll('.slide')

  slidesViewer: ->
    @_slidesViewer ||= document.querySelector(@identifier)

  start: ->
    @bodyClassList().add('loading')

    if !this.isFile()
      window.addEventListener('popstate', @handlePopState, false)

    document.addEventListener('click', @handleClick, false)
    document.addEventListener('keydown', @handleKeyDown, false)
    window.addEventListener('resize', @calculate, false)

    this.advanceTo(this.slideFromLocation())

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
    for slide in @allSlides()
      slide.style['width'] = "#{window.innerWidth}px"

      height = (window.innerHeight - slide.querySelector('.content').clientHeight) / 2

      slide.style['marginTop'] = "#{height}px"

    @slidesViewer().style['width'] = "#{window.innerWidth * @allSlides().length}px"
    this.align()

  align: =>
    @allSlides()[@priorSlide].classList.remove('active') if @priorSlide
    @allSlides()[@currentSlide].classList.add('active')

    @slidesViewer().style['left'] = "-#{@currentSlide * window.innerWidth}px"

    if @initialRender
      @bodyClassList().remove('loading')

      @initialRender = false

