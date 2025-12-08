/* 
  Simple drawing toy for the PicoCalc
  Allows drawing on the screen with the arrow keys
  Press number keys 0-9 to change color
  Press 'Enter' to draw a square at the current position
  Press 'S' to save the drawing to draw.bmp
  Press 'Q' to quit
*/

' colour palette
Dim integer clrs(10)
clrs(0) = RGB(black)
clrs(1) = RGB(white)
clrs(2) = RGB(cyan)
clrs(3) = RGB(blue)
clrs(4) = RGB(myrtle)
clrs(5) = RGB(green)
clrs(6) = RGB(yellow)
clrs(7) = RGB(rust)
clrs(8) = RGB(red)
clrs(9) = RGB(fuchsia)

' brush settings
Const blk = RGB(black)
Const brush = RGB(green)
Const bwd = 10
Dim integer pt.x = 0
Dim integer pt.y = 0
Dim integer c = RGB(white)
Dim integer exit_flag = 0

' create framebuffers
' sprite moves around layer l
' the drawing is painted to layer f
FRAMEBUFFER create
FRAMEBUFFER layer
FRAMEBUFFER write l
CLS blk

' create brush sprite
Sprite set transparent 0
Box pt.x,pt.y,bwd,bwd,1,brush,blk
Sprite read 2,pt.x,pt.y,bwd,bwd

' main loop
CLS blk
On key move
Do
 update
 Pause 100
Loop Until exit_flag = 1
CLS
End

Sub move
 Local string k$
 Local integer new.pt.y
 Local integer new.pt.x
 k$ = Inkey$
 Select Case Asc(k$)
 Case 128 'up
  new.pt.y = pt.y - bwd
  If new.pt.y > 0 Then
   pt.y = new.pt.y
  Else
   pt.y = 0
  End If
 Case 129 'down
  new.pt.y = pt.y + bwd
  If new.pt.y < MM.VRES Then pt.y=new.pt.y
 Case 130 'left
  new.pt.x = pt.x - bwd
  If new.pt.x > 0 Then
   pt.x = new.pt.x
  Else
   pt.x = 0
  End If
 Case 131 'right
  new.pt.x = pt.x + bwd
  If new.pt.x < MM.HRES Then pt.x=new.pt.x
 Case 13 'enter
  FRAMEBUFFER write f
  Box pt.x,pt.y,bwd,bwd,1,c,c
 Case 113 'quit
  exit_flag = 1
 Case 115 'save
  FRAMEBUFFER copy f,l
  Save image "draw.bmp"
 Case 48 To 57
  c = clrs(Asc(k$) - 48)
 End Select
End Sub

Sub update
 FRAMEBUFFER write l
 Sprite show 2,pt.x,pt.y,1
 FRAMEBUFFER merge 0
End Sub