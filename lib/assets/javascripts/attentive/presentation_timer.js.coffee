if !Attentive? then Attentive = {}

class Attentive.PresentationTimer
  constructor: ->
    @time = 0
    @el = null

  render: ->
    @ensureEl().innerHTML = this.formattedTime()

  ensureEl: ->
    if !@el
      @el = this._createDiv()
      @el.classList.add('timer')
    @el

  _createDiv: -> document.createElement('div')

  addClass: (className) ->
    @ensureEl().classList.add(className)

  start: ->
    @_runner = this.runner()
    this.addClass('running')

  runner: ->
    setTimeout(
      =>
        this.handleRunner()
      , 1000
    )

  handleRunner: ->
    this.render()
    @time += 1
    this.runner() if @_runner?

  stop: ->
    clearTimeout(@_runner)
    @ensureEl().classList.remove('running')
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
    @ensureEl().classList.toggle('hide')

  isVisible: ->
    !@ensureEl().classList.contains('hide')

  hide: ->
    @ensureEl().classList.add('hide')

  formattedTime: ->
    minute = "00#{Math.floor(@time / 60)}".slice(-2)
    second = "00#{@time % 60}".slice(-2)

    "#{minute}:#{second}"
