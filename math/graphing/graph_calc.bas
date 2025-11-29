Option explicit
Option angle degrees

'initialize vectors
Const MAXPTS = 100
Dim float x(MAXPTS)
Dim float y(MAXPTS)

'input functions
Dim string funx$
Dim string funy$
Dim float tmin : Dim float tmax

'set listener for keypress
On KEY keypress

ask:
CLS
Input "x(t)="; funx$
Input "y(t)="; funy$
Input "t range (min,max)"; tmin,tmax

CLS
draw_axes 10
draw_fun funx$, funy$, tmin, tmax
Pause 60000 'pause for a while
End

Sub keypress
 Local a$ As string
 a$ = Inkey$
 Select Case Asc(a$)
 Case 16 'ctrl-p for print screen
  Local fname$ As string
  fname$ = "screenshot-"+Str$(Rnd()*1000,0,0)+".bmp"
  Save Image fname$,0,0,319,319
 Case Else
  GoTo Ask
 End Select
End Sub


Sub fill_points funx$, funy$, numpts,   tmin, tmax
 Local integer n = numpts
 Local float max.x = 0.0
 Local float max.y = 0.0

 'generate points
 Local float min.t = tmin
 Local float max.t = tmax
 Local float delta.t =   (max.t-min.t)/n
 Local float t
 Local integer i
 For i=0 To n-1
  t = delta.t*i + min.t

  x(i) = Eval(funx$)
  If Abs(x(i))>max.x Then   max.x=Abs(x(i))

  y(i) = Eval(funy$)
  If Abs(y(i))>max.y Then   max.y=Abs(y(i))
 Next i

 'catch null graphs
 If max.x = 0 Then max.x = 1
 If max.y = 0 Then max.y = 1

 'add scale
 x(n) = max.x
 y(n) = max.y
End Sub

Sub draw_axes numticks
 Local integer mcount = numticks

 'draw axes
 Local integer xaxis, yaxis
 xaxis = MM.VRES\2
 Line 0,xaxis,MM.HRES,xaxis,, RGB(green)
 Text MM.HRES-1,xaxis-1,"x axis", "RB",7

 yaxis = MM.HRES\2
 Line yaxis,0,yaxis,MM.VRES,, RGB(green)
 Text yaxis-1,1,"y axis","RT",7

 'draw ticks
 Local integer i
 Local float dx, dy
 dx = MM.HRES/mcount
 dy = MM.VRES/mcount
 For i=0 To mcount
  Pixel yaxis+1,Int(i*dy),RGB(green)
  Pixel Int(i*dx),xaxis+1,RGB(green)
 Next i
End Sub

Sub draw_fun funx$, funy$, tmin, tmax
 Local integer i
 Local float nx.pt.x, nx.pt.y
 Local float ls.pt.x, ls.pt.y

 'load plotting arrays
 fill_points funx$,funy$,MAXPTS,tmin, tmax
 Local float max.x = x(MAXPTS)
 Local float max.y = y(MAXPTS)

 'scale plot
 Local float o.x = MM.HRES/2
 Local float o.y = MM.VRES/2
 Local float scl.x = (o.x-2)/max.x
 Local float scl.y = (o.y-2)/max.y

 Text MM.HRES-1,Int(o.y+2), Str$(max.x,0,3),"RT",7
 Text Int(o.x+2),1,Str$(max.y,0,3), "LT",7

 'draw parametric equations
 ls.pt.x = scl.x*x(0) + o.x
 ls.pt.y = o.y - scl.y*y(0)

 For i=1 To (MAXPTS-1)
  nx.pt.x = scl.x*x(i) + o.x
  nx.pt.y = o.y - scl.y*y(i)

  Line Int(ls.pt.x),Int(ls.pt.y), Int(nx.pt.x),Int(nx.pt.y),1,RGB(blue)

  ls.pt.x = nx.pt.x
  ls.pt.y = nx.pt.y

  Pause 10
 Next i
End Sub
