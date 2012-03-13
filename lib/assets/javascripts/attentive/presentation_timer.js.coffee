if !Attentive? then Attentive = {}

class Attentive.PresentationTimer
  constructor: ->
    @time = 0
    @el = null

  render: ->
    @ensureEl().innerHTML = this.formattedTime()

  ensureEl: ->
    if !@el
      @el = document.createElement('div')
      @el.classList.add('timer')
    @el

  start: ->
    @_runner = this.runner()
    @ensureEl().classList.add('running')

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
