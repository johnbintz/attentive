#= require attentive/presentation_timer

describe 'Attentive.PresentationTimer', ->
  beforeEach ->
    @timer = new Attentive.PresentationTimer()

  describe '#render', ->
    time = 'time'
    elStub = null

    beforeEach ->
      elStub = {}
      @timer.ensureEl = -> elStub
      @timer.formattedTime = -> time

    it 'should render', ->
      @timer.render()
      expect(elStub.innerHTML).toEqual(time)

  describe '#ensureEl', ->
    context 'with el', ->
      el = 'el'

      beforeEach ->
        @timer.el = el

      it 'should return the existing value', ->
        expect(@timer.ensureEl()).toEqual(el)

    context 'without el', ->

