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
Const snklen = 10 'snake length
Const snkw = 10 'width of snake segments
Dim integer px = w\2 'head x position
Dim integer py = h\2 'head y position
Dim integer vx=1 'head x velocity
Dim integer vy=0 'heax y velocity

'create a box for each snake segment
'read it into a sprite
Sprite set transparent 0
For i=0 To snklen
 Box px,py,snkw,snkw,2,snk,snk
 Sprite read i+2,px,py,snkw,snkw
Next i

'initialize snake head and body positions
Dim x(snklen), y(snklen)
For i=0 to snklen
 x(i) = px - i*snkw
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
 px = px + vx*snkw
 If px > w-snkw Then px=w-snkw:vx=-1*vx
 If px < 1 Then px=1:vx=-1*vx

 'update y
 py = py + vy*snkw
 If py > h-snkw Then py=h-snkw:vy=-1*vy
 If py < 1 Then py=1:vy=-1*vy
End Sub

Sub changedir
 Local string k$
 k$ = Inkey$
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
 For i=snklen To 1 Step -1
  x(i) = x(i-1)
  y(i) = y(i-1)
 Next i
 x(0) = px
 y(0) = py
End Sub

Sub draw
 For i=0 To snklen
  If x(i)>0 And y(i)>0 Then
   'update sprite positions
   Sprite next i+2,x(i),y(i)
  End If
 Next i
 Sprite move 'move all sprites
 FRAMEBUFFER copy f,n
End Sub
