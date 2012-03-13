Flowerbox.World ->
  @addMatchers(
    toBeRunning: () ->
      @message = "Expected #{@notMessage} be running"
      @actual._runner?
  )

