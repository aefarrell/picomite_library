print "press any key"
mainloop:
  a$ = inkey$
  if a$="" then goto mainloop
  
  print "key pressed: " asc(a$)
  
  goto mainloop
  