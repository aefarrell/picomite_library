/*
Simple drawing toy for the PicoCalc
Allows drawing on the screen with the
arrow keys

Number keys 0-9 change the color
Enter fills in the square
's' saves the drawing to draw.bmp
'q' to quit
*/

' colour palette
dim integer clrs(10)
clrs(0) = rgb(black)
clrs(1) = rgb(white)
clrs(2) = rgb(cyan)
clrs(3) = rgb(blue)
clrs(4) = rgb(myrtle)
clrs(5) = rgb(green)
clrs(6) = rgb(yellow)
clrs(7) = rgb(rust)
clrs(8) = rgb(red)
clrs(9) = rgb(fuchsia)

' brush settings
const blk = rgb(black)
const brush = rgb(green)
const bwd = 10
dim integer pt.x = 0
dim integer pt.y = 0
dim integer c = rgb(white)
dim integer exit_flag = 0

' default filename
dim string fname$ = "draw"
dim string ext$ = ".bmp"

' create framebuffers
' sprite moves around layer l
' the drawing is painted to layer f
framebuffer create
framebuffer layer
framebuffer write l
cls blk

' create brush sprite
sprite set transparent 0
box pt.x,pt.y,bwd,bwd,1,brush,blk
sprite read 2,pt.x,pt.y,bwd,bwd

' main loop
cls blk
on key move
do
 update
 pause 100
loop until exit_flag = 1
cls
end

sub move
 local string k$
 local integer new.pt.y
 local integer new.pt.x
 k$ = inkey$
 select case asc(k$)
 case 128 'up
  new.pt.y = pt.y - bwd
  if new.pt.y > 0 then
   pt.y = new.pt.y
  else
   pt.y = 0
  end if
 case 129 'down
  new.pt.y = pt.y + bwd
  if new.pt.y < MM.VRES then pt.y=new.pt.y
 case 130 'left
  new.pt.x = pt.x - bwd
  if new.pt.x > 0 then
   pt.x = new.pt.x
  else
   pt.x = 0
  end if
 case 131 'right
  new.pt.x = pt.x + bwd
  if new.pt.x < MM.HRES then pt.x=new.pt.x
 case 13 'enter
  framebuffer write f
  box pt.x,pt.y,bwd,bwd,1,c,c
 case 113 'quit
  exit_flag = 1
 case 115 'save
  framebuffer copy f,l
  local string fn$ = filename()
  save image fn$
 case 48 to 57
  c = clrs(asc(k$) - 48)
 end select
end sub

sub update
 framebuffer write l
 sprite show 2,pt.x,pt.y,1
 framebuffer merge 0
end sub

function filename() as string
local string f$ = dir$(fname$+"*"+ext$,FILE)
local integer i = 0
do while f$ <> ""
  inc i
  f$ = dir$()
loop
local string copies = ""
if i > 0 then
 copies = "-"+format$(i)
end if
filename = fname$+copies+ext$
end function