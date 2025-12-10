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

Option explicit

Dim float p 'principle
Dim float r 'interest rate
Dim float m 'monthly payment
Dim integer payoff 'time till paid off
Dim integer yrs 'years
Dim integer n 'number of periods

start:
CLS RGB(black)
Print "Mortgage Calculator"
Print "-------------------"
Input "Loan Amount    : $", p
Input "Int. Rate (APR): %", r
Input "Number of Years:  ", yrs

If r<0 Or r>100 Then
 Print "Interest rate must be 0%<r<100%"
 GoTo start
End If

n = 12*yrs
r = r/100/12
m = payment(p,r,n)
payoff = n

Dim float bal(n) 'remaining balance
Dim float itr(n) 'interest'
Dim float pmts(n) 'payments
Array Set m, pmts()
amort
balplot

Dim integer exit_flag=0
On key opts
Do While exit_flag=0
 Pause 100
Loop

End

' functions
Function payment(p0,r,n) As float
 payment = (p0*r)/(1-(1+r)^-n)
End Function

Function balance(p0,r,i,n) As float
 Local float a, c
 a = (1+r)^i
 c = payment(p0,r,n)
 balance = p0*a - c*(a-1)/r
End Function

' subroutines
Sub addpmt
 Local float apmt
 Local integer mnth
 Input "Add Payment:$",apmt
 Input "Pay Period : ",mnth
 If mnth>=0 And mnth<=n Then
  pmts(mnth) = pmts(mnth) + apmt
 Else
  Print "invalid pay period"
 End If
End Sub

Sub modpmt
 Local float cpmt
 Local integer start,stop,i
 Input "Modified Payment:$",cpmt
 Input "Pay Period Start: ",start
 Input "Pay Period Stop : ",stop
 If start>=0 And stop<=n Then
  For i=start To stop
   pmts(i) = cpmt
  Next i
 Else
  Print "invalid pay periods"
 End If
End Sub

Sub amort
 Local integer i
 Local float it
 Local float newbal
 bal(0) = p
 itr(0) = 0
 pmts(0) = 0
 For i=1 To n
  it = bal(i-1)*r
  newbal = bal(i-1) + it - pmts(i)
  itr(i) = it
  If newbal > 0 Then
   bal(i) = newbal
  Else
   ' loan paid off
   payoff = i
   bal(i) = 0
   pmts(i) = bal(i-1) + it
   Local integer j
   For j=i+1 To n
    bal(j)  = 0
    itr(j)  = 0
    pmts(j) = 0
   Next j
   Exit For
  End If
 Next i
End Sub

Sub printsum nbr
 Local string l1$,l2$,l3$,l4$,l5$,l6$, fmt$
 l1$ = "Initial Loan   : "
 l2$ = "Monthly Payment: "
 l3$ = "Total Paid     : "
 l4$ = "Interest Paid  : "
 l5$ = "Loan Repayment : "
 l6$ = "Interest Saved : "
 fmt$ = "$%10.2f"

 Cat l1$,Format$(p,fmt$)
 Cat l2$,Format$(m,fmt$)
 Cat l3$,Format$(Math(sum pmts()),fmt$)

 Local float ipmt
 ipmt = Math(sum itr())
 Cat l4$,Format$(ipmt, fmt$)

 Local integer years, months
 years = payoff\12
 months = payoff - 12*years
 Cat l5$,Format$(years," %g years")
 Cat l5$,Format$(months," %g months")
 Cat l6$,Format$(n*m-p-ipmt,fmt$)

 Print #nbr, l1$
 Print #nbr, l2$
 Print #nbr, l3$
 Print #nbr, l4$
 Print #nbr, l5$
 Print #nbr, "----------------------"
 Print #nbr, l6$

End Sub

Sub balplot
 Local float x(n),y(n),yo(n)
 Local integer x1,x2,y1,y2
 x1 = 5 : x2 = MM.HRES-5
 y1 = 0 : y2 = MM.VRES\2

 Local integer i
 For i=0 To n
  x(i) = i
  yo(i) = balance(p,r,i,n)
 Next i
 Math window x(),x1,x2,x()
 Math window yo(),y2,y1,yo()
 Math window bal(),y2,y1,y()

 CLS RGB(black)
 Line graph x(),yo(),RGB(red)
 Line graph x(),y(),RGB(green)
 Line x1,y1,x1,y2,1,RGB(white)
 Line x1,y2,x2,y2,1,RGB(white)

 Local integer xtks,xscl,ytks,yscl
 xtks = yrs
 xscl = (x2-x1)\xtks
 ytks = Fix(p/10000)
 yscl = (y2-y1)\ytks
 For i=0 To ytks
  Pixel x1-1,y1+i*yscl,RGB(green)
 Next i

 For i=0 To xtks
  Pixel x1+i*xscl,y2+1,RGB(green)
 Next i

 Print @(0,y2) ""
 printsum 0

End Sub

Sub printfile
 Local string fname$
 Local string fmt$ = "   $%8.2f "
 Line Input "Filename:",fname$
 Open fname$ For output As #1
 printsum 1
 Local string hd$
 hd$ = " Period "
 Cat hd$,"    Interest "
 Cat hd$,"     Payment "
 Cat hd$,"   Remaining "
 Print #1,""
 Print #1,hd$
 Print #1,"----------------------------------------------"
 Local integer i
 Local string l$
 For i=0 To n
  l$ = Format$(i,"  %3.0f  ")
  Cat l$,Format$(itr(i),fmt$)
  Cat l$,Format$(pmts(i),fmt$)
  Cat l$,Format$(bal(i),fmt$)
  Print #1,l$
 Next i
 Close #1
 Print #0,"Done."
End Sub

Sub opts
 Local string k$
 k$ = Inkey$
 Select Case Asc(k$)
 Case 97  'a
  addpmt
  amort
  CLS RGB(black)
  balplot
 Case 109 'm
  modpmt
  amort
  CLS RGB(black)
  balplot
 Case 112 'p
  printfile
 Case 114 'r
  Array Set m, pmts()
  amort
  CLS RGB(black)
  balplot
 Case 113 'q
  exit_flag = 1
 Case 104 'h
  Print "a) Additional payment"
  Print "m) Modify payment schedule"
  Print "p) Print result to text file"
  Print "r) Reset"
  Print "q) Quit"
  Print "h) Help"
 End Select
End Sub