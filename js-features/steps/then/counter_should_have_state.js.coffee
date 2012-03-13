Flowerbox.Then /^the counter (should|should not) be running$/, (state) ->
  switch state
    when 'should'
      @expect(@timer).toBeRunning()
    when 'should not'
      @expect(@timer).not.toBeRunning()

