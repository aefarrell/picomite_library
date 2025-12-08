/*
  A simple snake toy using sprites
  Use arrow keys to change direction
  q to quit
*/
'double buffer animation
FRAMEBUFFER create
FRAMEBUFFER write f
CLS RGB(black)

'window dimensions
Const w = MM.HRES : Const h =  MM.VRES
Dim integer i
Dim integer exit_flag = 0

'snake properties
Const snk = RGB(yellow) 'snake color
Const snklen = 25 'snake length
Const snkw = 5 'width of snake segments
Dim integer px = w\2 'head x position
Dim integer py = h\2 'head y position
Dim integer vx=1 'head x velocity
Dim integer vy=0 'heax y velocity
Dim integer stop_flag=0 'snake stopped?

'create a box for each snake segment
'read it into a sprite
Const hdid = 2
Sprite set transparent 0
Box px,py,snkw,snkw,2,snk,snk
Sprite read hdid,px,py,snkw,snkw
Sprite copy hdid,hdid+1,snklen

'save a red sprite for collisions
Const hit = RGB(red)
Const colid = snklen+3
Box px,py,snkw,snkw,2,hit,hit
Sprite read colid,px,py,snkw,snkw


'initialize snake head and body positions
Dim x(snklen), y(snklen)
For i=0 To snklen
 x(i) = px - i*(snkw+1)
 y(i) = py
Next i

'draw play field
CLS RGB(black)
Box 0,0,w,h,2,RGB(blue)
For i=0 To snklen
 Sprite show i+2,x(i),y(i),1
Next i

'main loop
On key changedir
Sprite interrupt collision
Do
 move
 update
 draw
 Pause 100
Loop Until exit_flag = 1
CLS
End

Sub move
 'update x
 new.px = px + vx*(snkw+1)
 If new.px > w-snkw Then new.px=px:collision
 If new.px < 1 Then new.px=px:collision
 px = new.px

 'update y
 new.py = py + vy*(snkw+1)
 If new.py > h-snkw Then new.py=py:collision
 If new.py < 1 Then new.py=py:collision
 py = new.py
End Sub

Sub changedir
 Local string k$
 k$ = Inkey$

 'reset snake head
 If stop_flag = 1 Then
  stop_flag = 0
  Sprite swap colid,hdid
 End If

 'select direction of travel
 Select Case Asc(k$)
  Case 128 'up arrow
   vx = 0
   vy = -1
  Case 129 'down arrow
   vx = 0
   vy = 1
  Case 130 'left arrow
   vx = -1
   vy = 0
  Case 131 'right arrow
   vx = 1
   vy = 0
  Case 113 'q
   exit_flag = 1
  Case Else
   Print "I don't know that one"
 End Select
End Sub

Sub update
 If stop_flag = 0 Then
  For i=snklen To 1 Step -1
   x(i) = x(i-1)
   y(i) = y(i-1)
  Next i
  x(0) = px
  y(0) = py
 End If
End Sub

Sub draw
 If stop_flag = 0 Then
  For i=0 To snklen
   Sprite next i+hdid,x(i),y(i)
  Next i
  Sprite move 'move all sprites
  FRAMEBUFFER copy f,n
 End If
End Sub

Sub collision
 If stop_flag = 0 Then
  stop_flag=1
  vx=0:vy=0
  Play tone 1000,1000,250
  Sprite swap hdid,colid
  FRAMEBUFFER copy f,n
  Save image "snake.bmp"
 End If
End Sub