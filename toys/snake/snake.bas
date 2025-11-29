'double buffer animation
FRAMEBUFFER create
FRAMEBUFFER write f

'window dimensions and initial  position
Const w = MM.HRES : Const h =  MM.VRES
Dim integer hx = w\2
Dim integer hy = h\2
Dim integer exit_flag = 0

'set up sprites
Const spid0 = 1
Const max_sps = 10
Const spw = 10
Dim integer c=RGB(blue)
Dim integer snk=RGB(yellow)
CLS
Sprite set transparent 0
Dim integer i
For i=1 To max_sps
 'create a sprite for each segment
 Box hx,hy,spw,spw,2,snk,snk
 'Circle hx+spw\2,hy+spw\2,spw\2,2,1,snk,snk
 Sprite read spid0+i,hx,hy,spw,spw
Next i

'set snake head and body
Dim x(max_sps), y(max_sps)
For i=1 To max_sps
 x(i) = hx - (i-1)*spw
 y(i) = hy
Next i

'snake velocity
Dim integer vx=1: Dim integer vy=0

CLS RGB(black)
Box 0,0,w,h,2,c
draw
On key changedir

Do
 CLS RGB(black)
 Box 0,0,w,h,2,c
 move
 update
 draw
 Pause 100
Loop Until exit_flag = 1

CLS
End

Sub move
 'update x
 hx = hx + vx*spw
 If hx > w-spw Then hx=w-spw:vx=-1*vx
 If hx < 1 Then hx=1:vx=-1*vx

 'update y
 hy = hy + vy*spw
 If hy > h-spw Then hy=h-spw:vy=-1*vy
 If hy < 1 Then hy=1:vy=-1*vy
End Sub

Sub changedir
 k$ = Inkey$
 Select Case Asc(k$)
  Case 128
   vx = 0
   vy = -1
  Case 129
   vx = 0
   vy = 1
  Case 130
   vx = -1
   vy = 0
  Case 131
   vx = 1
   vy = 0
  Case 113
   exit_flag = 1
  Case Else
   Print "I don't know that one"
 End Select
End Sub

Sub update
 For i=max_sps To 2 Step -1
  x(i) = x(i-1)
  y(i) = y(i-1)
 Next i
 x(1) = hx
 y(1) = hy
End Sub

Sub draw
 For i=1 To max_sps
  If x(i)>0 And y(i)>0 Then
   Sprite show spid0+i,x(i),y(i),1
  End If
 Next i
 FRAMEBUFFER copy f,n
End Sub
