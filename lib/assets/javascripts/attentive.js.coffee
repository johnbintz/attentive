#= require jquery
#= require fathom

$(->
  fathom = new Fathom('#slides', displayMode: 'multi', scrollLength: 250)

  setTimeout(
    ->
      $(window).trigger('resize')
    , 500
  )
)

