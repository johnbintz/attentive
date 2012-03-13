#= require attentive/presentation_timer
#
Flowerbox.Given /I have a presentation counter/, ->
  @timer = new Attentive.PresentationTimer()
  @timer.render()
