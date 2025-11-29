'the most annoying musical instrument

Const blk = RGB(black)
Const cyn = RGB(cyan)
Const wht = RGB(white)

Const pad = 5
Const w = MM.HRES-2*pad
Const h = MM.VRES-2*pad

GUI delete all
Font 1
CLS blk
GUI frame #1,"tedious tone  generator",pad,pad,w,h,wht

Const mnhz = 300
Const mxhz = 2000
Const dlthz = 100

Const ctr.x = MM.HRES/2
Const ctr.y = MM.VRES/2
GUI gauge #2,ctr.x,ctr.y,120,wht,blk,   mnhz, mxhz, 0, "Hz", cyn, mxhz

Dim f = mnhz

On KEY incr

Do
  CtrlVal(#2) = f
  Play tone f,f, 100
Loop

Sub incr
  a$ = Inkey$
  Select Case Asc(a$)
  Case 128
    f = Min(f+dlthz,mxhz)
  Case 129
    f = Max(f-dlthz,mnhz)
  case 113
    end
  End Select
End Sub

sub MM.END
  print "thanks for playing"
end sub
