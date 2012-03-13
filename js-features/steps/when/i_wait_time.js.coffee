Flowerbox.When /^I wait (\d+) seconds?$/, (secs) ->
  Flowerbox.pause(Number(secs) * 1000)

