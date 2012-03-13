Flowerbox.Then /^the counter (should|should not) show the time "([^"]+)"$/, (state, time) ->
  content = @timer.ensureEl().innerHTML

  switch state
    when 'should'
      @expect(content).toEqual(time)
    when 'should not'
      @expect(content).not.toEqual(time)
