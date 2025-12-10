/* Runge-Kutta 4th Order ODE Integrator

Integrates the ODE system using RK-4
with a fixed step size.

Arguments:
fname$ - function name of rhs of od
         function signature must
         follow
         fn(t,y(),o())
         where the result is returned
         in-place in the array o
         function returns 1 for success
         and 0 to terminate integration
y0(n)  - array of initial conditions
t0     - initial value of t
dt     - fixed time step
o(n,m) - pre-allocated output array
         n variables
         m timesteps
*/
Sub rk4 fname$,y0(),t0,dt,o()
 'check bounds of arrays
 Local integer l = Bound(o(),0)
 Local integer n = Bound(o(),1)
 Local integer m = Bound(o(),2)

 If Bound(y0(),0) <> l Then
  Error "y0 and o must start at the same index"
 End If

 If Bound(y0(),1) <> n Then
  Error "array size mismatch"
 End If

 'initialize loop variables
 Local integer i,j,flag
 Dim float k1(n),k2(n),k3(n),k4(n)
 Dim float yi(n),a(n)
 Dim float ti = t0
 Array Add y0(),0,yi()
 Array Insert o(),,l,y0()

 'main loop
 For i=l+1 To m
  Array Add yi(),0,a()
  flag = Call(fname$,ti,a(),k1())

  'check flag and terminate early
  If flag=0
   Exit For
  End If

  Math scale k1(),0.5*dt,a()
  Math c_add yi(),a(),a()
  flag = Call(fname$,ti+0.5*dt,a(),k2())

  Math scale k2(),0.5*dt,a()
  Math c_add yi(),a(),a()
  flag = Call(fname$,ti+0.5*dt,a(),k3())

  Math scale k3(),dt,a()
  Math c_add yi(),a(),a()
  flag = Call(fname$,ti+dt,a(),k4())

  Math scale k1(),dt/6,k1()
  Math scale k2(),dt/3,k2()
  Math scale k3(),dt/3,k3()
  Math scale k4(),dt/6,k4()

  Array Set 0,a()
  Math c_add yi(),k1(),a()
  Math c_add a(),k2(),a()
  Math c_add a(),k3(),a()
  Math c_add a(),k4(),a()

  ti = ti+dt
  Array Add a(),0,yi()
  Array Insert o(),,i,yi()
 Next i
End Sub