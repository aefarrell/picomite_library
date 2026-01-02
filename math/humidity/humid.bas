/*
 HUMIDITRON
 calculates indoor relative humidity based on outdoor conditions
 and indoor temperature
 Up and Down arrows select input boxes
 Enter to edit selected box
 F and C keys set units
 Q to quit
*/

option base 0

'globals for screen state and colour
dim string inp = ""
dim integer sel = 2
const max.sel = 2
dim integer inp_boxes(2) = (24,34,32)
const in.fg = rgb(orange)
const in.bg = rgb(black)
const in.sl = rgb(rust)
const out.fg = rgb(cerulean)
const out.bg = rgb(black)
const out.sl = rgb(cobalt)

'display units
dim integer units = 0
dim string unit$ = "`C"
dim string fmt = "%3.2f"

'state variables
dim float in.RH = 50.0
dim float in.T = 20.0
dim float out.RH = 50.0
dim float out.T = 20.0

'Paul R. Lowe, "An Approximating
'Polynomial for the Computation of
'Saturation Vapor Pressure," *Journal
'of Applied Meteorology and
'Climatology*, 16(1977): 100-103
data 6.107799961,4.436518521e-1
data 1.428945805e-2,2.650648471e-4
data 3.031240396e-6,2.034080948e-8
data 6.136820929e-11
dim float a(6)
read a()

'main program
cls rgb(black)
draw_ui
up_vals
sel_inp
on KEY menu

do
 pause 100
loop

'functions
function Es(T as float) as float
 local integer i
 Es = a(6)
 for i=5 to 0 step -1
  Es = a(i) + T*Es
 next i
end function

function bounded(val as float,mn as float, mx as float) as float
 if val < mn then
  bounded = mn
 elseif val > mx then
  bounded = mx
 else
  bounded = val
 end if
end function

function cnv_out(T as float, u as integer) as float
  cnv_out = choice(u=0,T,T*9/5+32)
end function

function cnv_inp(T as float, u as integer) as float
  cnv_inp = choice(u=0,T,(T-32)*5/9)
end function

'subroutines
sub menu
 local integer k = asc(inkey$)
 select case k
 case 128 'up
  sel = choice(sel<max.sel,sel+1,0)
  sel_inp
 case 129 'down
  sel = choice(sel>0,sel-1,max.sel)
  sel_inp
 case 102 'f
  units = 1 'Farenheit
  unit$ = "`F"
  up_vals
 case 99  'c
  units = 0 'Celsius
  unit$ = "`C"
  up_vals
 case 13  'enter
  inp = "" 'clear input buffer
  on key 0 'disable menu
  gui bcolour rgb(white),#inp_boxes(sel)
  gui fcolour rgb(black),#inp_boxes(sel)
  on key cap_inp
 case 113 'q
  end
 end select
end sub

sub up_vals
 validate_inps
 calc_in_RH
 ctrlval(#20) = in.RH
 ctrlval(#22) = format$(in.RH,fmt)+"%"
 ctrlval(#30) = out.RH
 ctrlval(#32) = format$(out.RH,fmt)+"%"

 static string inside
 static string outside
 local float iT, oT
 iT = cnv_out(in.T,units)
 oT = cnv_out(out.T,units)
 inside = format$(iT,fmt)+unit$
 outside = format$(oT,fmt)+unit$
 ctrlval(#10) = units
 ctrlval(#24) = inside
 ctrlval(#34) = outside
end sub

sub validate_inps
 in.T = bounded(in.T,-50.0,50.0)
 out.T = bounded(out.T,-50.0,50.0)
 out.RH = bounded(out.RH,0.0,100.0)
end sub

sub calc_in_RH
 local float out.Es,out.Ea,in.Es
 out.Es = Es(out.T)
 out.Ea = out.RH*out.Es/100
 in.Es  = Es(in.T)
 in.RH  = out.Ea/in.Es*100
 in.RH = bounded(in.RH,0.0,100.0)
end sub

sub sel_inp
 gui bcolour in.bg,#24
 gui fcolour in.fg,#24
 gui bcolour out.bg,#32,#34
 gui fcolour out.fg,#32,#34
 if sel > 0 then
  gui bcolour out.sl,#inp_boxes(sel)
 else
  gui bcolour in.sl,#inp_boxes(sel)
 end if
end sub

sub ch_inp
 local float rw_inp = val(inp)
 select case sel
 case 2 'outside RH
  out.rh = rw_inp
 case 1 'outside T
  out.T = cnv_inp(rw_inp,units)
 case 0 'inside T
  in.T = cnv_inp(rw_inp,units)
 end select
end sub

sub cap_inp
 local string s = inkey$
 if asc(s) <> 13 then 'enter
  inp = inp + s
  ctrlval(#inp_boxes(sel)) = inp
 else
  on key 0
  on key menu
  ch_inp
  up_vals
  sel_inp
 end if
end sub

sub draw_ui
'title
font 3,1
gui caption #74,"HUMIDITRON",15,35,"LB",rgb(cyan),rgb(black)

font 1
'unit box
gui frame #1,"Units",255,10,50,35,rgb(fuchsia)
gui switch #10,"`C|`F",260,22,40,10,rgb(white),rgb(magenta)
ctrlval(#10) = 0

'inside
gui frame #2,"Inside",165,50,150,150,in.fg
gui bargauge #20,175,65,20,120,in.fg,in.bg,0,100
gui caption #21,"Rel. Humidity",200,90,"LB",in.fg,in.bg
gui displaybox #22,200,95,100,20,in.fg,in.bg
gui caption #23,"Temperature",200,140,"LB",in.fg,in.bg
gui displaybox #24,200,145,100,20,in.fg,in.bg

'outside
gui frame #3,"Outside",5,50,150,150,out.fg
gui bargauge #30,125,65,20,120,out.fg,out.bg,0,100
gui caption #31,"Rel. Humidity",10,90,"LB",out.fg,out.bg
gui displaybox #32,10,95,100,20,out.fg,out.bg
gui caption #33,"Temperature",10,140,"LB",out.fg,out.bg
gui displaybox #34,10,145,100,20,out.fg,out.bg
end sub