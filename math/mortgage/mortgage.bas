/*
Mortgage Calculator
Calculates mortgage payments, amort-
-ization schedule, and plots balance
over time.
Assumes the mortgage compounds monthly.
After the initial amortization schedule
is calculated, the user can add
payments or modify the payment schedule

a) Add a payment at a specific period
m) Modify the payments over a range
p) Print the results to a text file
r) Reset the payment schedule
q) Quit the program
h) Help - display the options

*/

option explicit

dim float p 'principle
dim float r 'interest rate
dim float m 'monthly payment
dim integer payoff 'time till paid off
dim integer yrs 'years
dim integer n 'number of periods

start:
cls rgb(black)
print "Mortgage Calculator"
print "-------------------"
input "Loan Amount    : $", p
input "Int. Rate (APR): %", r
input "Number of Years:  ", yrs

if r<0 or r>100 then
 print "Interest rate must be 0%<r<100%"
 goto start
end if

n = 12*yrs
r = r/100/12
m = payment(p,r,n)
payoff = n

dim float bal(n) 'remaining balance
dim float itr(n) 'interest'
dim float pmts(n) 'payments
array set m, pmts()
amort
balplot

dim integer exit_flag=0
on key opts
do while exit_flag=0
 pause 100
loop

end

' functions
function payment(p0,r,n) as float
 payment = (p0*r)/(1-(1+r)^-n)
end function

function balance(p0,r,i,n) as float
 local float a, c
 a = (1+r)^i
 c = payment(p0,r,n)
 balance = p0*a - c*(a-1)/r
end function

' subroutines
sub addpmt
 local float apmt
 local integer mnth
 input "Add Payment:$",apmt
 input "Pay Period : ",mnth
 if mnth>=0 and mnth<=n then
  pmts(mnth) = pmts(mnth) + apmt
 else
  print "invalid pay period"
 end if
end sub

sub modpmt
 local float cpmt
 local integer start,stop,i
 input "Modified Payment:$",cpmt
 input "Pay Period Start: ",start
 input "Pay Period Stop : ",stop
 if start>=0 and stop<=n then
  for i=start to stop
   pmts(i) = cpmt
  next i
 else
  print "invalid pay periods"
 end if
end sub

sub amort
 local integer i
 local float it
 local float newbal
 bal(0) = p
 itr(0) = 0
 pmts(0) = 0
 for i=1 to n
  it = bal(i-1)*r
  newbal = bal(i-1) + it - pmts(i)
  itr(i) = it
  if newbal > 0 then
   bal(i) = newbal
  else
   ' loan paid off
   payoff = i
   bal(i) = 0
   pmts(i) = bal(i-1) + it
   local integer j
   for j=i+1 to n
    bal(j)  = 0
    itr(j)  = 0
    pmts(j) = 0
   next j
   exit for
  end if
 next i
end sub

sub printsum nbr
 local string l1$,l2$,l3$,l4$,l5$,l6$, fmt$
 l1$ = "Initial Loan   : "
 l2$ = "Monthly Payment: "
 l3$ = "Total Paid     : "
 l4$ = "Interest Paid  : "
 l5$ = "Loan Repayment : "
 l6$ = "Interest Saved : "
 fmt$ = "$%10.2f"

 cat l1$,format$(p,fmt$)
 cat l2$,format$(m,fmt$)
 cat l3$,format$(math(sum pmts()),fmt$)

 local float ipmt
 ipmt = math(sum itr())
 cat l4$,format$(ipmt, fmt$)

 local integer years, months
 years = payoff\12
 months = payoff - 12*years
 cat l5$,format$(years," %g years")
 cat l5$,format$(months," %g months")
 cat l6$,format$(n*m-p-ipmt,fmt$)

 print #nbr, l1$
 print #nbr, l2$
 print #nbr, l3$
 print #nbr, l4$
 print #nbr, l5$
 print #nbr, "----------------------"
 print #nbr, l6$

end sub

sub balplot
 local float x(n),y(n),yo(n)
 local integer x1,x2,y1,y2
 x1 = 5 : x2 = MM.HRES-5
 y1 = 0 : y2 = MM.VRES\2

 local integer i
 for i=0 to n
  x(i) = i
  yo(i) = balance(p,r,i,n)
 next i
 math window x(),x1,x2,x()
 math window yo(),y2,y1,yo()
 math window bal(),y2,y1,y()

 cls rgb(black)
 line graph x(),yo(),rgb(red)
 line graph x(),y(),rgb(green)
 line x1,y1,x1,y2,1,rgb(white)
 line x1,y2,x2,y2,1,rgb(white)

 local integer xtks,xscl,ytks,yscl
 xtks = yrs
 xscl = (x2-x1)\xtks
 ytks = fix(p/10000)
 yscl = (y2-y1)\ytks
 for i=0 to ytks
  pixel x1-1,y1+i*yscl,rgb(green)
 next i

 for i=0 to xtks
  pixel x1+i*xscl,y2+1,rgb(green)
 next i

 print @(0,y2) ""
 printsum 0

end sub

sub check_file fn$ as string
local integer dot = instr(fn$,".")
local string name = left$(fn$,dot-1)
local string ext = right$(fn$,len(fn$)-dot)
local string f$ = dir$(name+"*."+ext,FILE)
local integer i = 0
do while f$ <> ""
 inc i
 f$ = dir$()
loop
local string copies = ""
if i > 0 then
 copies = "-"+format$(i)
end if
fn$ = name+copies+"."+ext
end sub

sub printfile
 local string fname$ = ""
 local string fmt$ = "   $%8.2f "
 line input "Filename:",fname$
 check_file fname$
 open fname$ for output as #1
 printsum 1
 local string hd$
 hd$ = " Period "
 cat hd$,"    Interest "
 cat hd$,"     Payment "
 cat hd$,"   Remaining "
 print #1,""
 print #1,hd$
 print #1,"----------------------------------------------"
 local integer i
 local string l$
 for i=0 to n
  l$ = format$(i,"  %3.0f  ")
  cat l$,format$(itr(i),fmt$)
  cat l$,format$(pmts(i),fmt$)
  cat l$,format$(bal(i),fmt$)
  print #1,l$
 next i
 close #1
 print #0,"Done."
end sub

sub opts
 local string k$
 k$ = inkey$
 select case asc(k$)
 case 97  'a
  addpmt
  amort
  cls rgb(black)
  balplot
 case 109 'm
  modpmt
  amort
  cls rgb(black)
  balplot
 case 112 'p
  printfile
 case 114 'r
  array set m, pmts()
  amort
  cls rgb(black)
  balplot
 case 113 'q
  exit_flag = 1
 case 104 'h
  print "a) Additional payment"
  print "m) Modify payment schedule"
  print "p) Print result to text file"
  print "r) Reset"
  print "q) Quit"
  print "h) Help"
 end select
end sub