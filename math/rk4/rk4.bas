/* Runge-Kutta 4th Order ODE Integrator

rk4 fname$,y0(),t0,dt,o()

Integrates the ODE system using RK-4
with a fixed step size.

Arguments:
fname$ - function name of rhs of ode
         fname(t,y(),o())
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
Function rk4step(fname$,yt(),t,dt) as integer
 'initialize bounds on arrays
 Static integer l = Bound(yt(),0)
 Static integer n = Bound(yt(),1)

 'rk arrays
 Static float dts(2+l) = (0.5*dt,0.5*dt,dt)
 Static float rks(3+l) = (dt/6,dt/3,dt/3,dt/6)
 Static float s(n),a(n),k(n)
 Array Set 0,s()
 Array Add yt(),0,k()

 'integration step
 Local integer i
 For i=l To 3+l
  'k_{i} = f(t+dts_i,y_{t}+dts_i*k_i)
  flag = Call(fname$,t,k(),k())
  If flag=0 Then
   rk4step=0
   Exit Function
  End If

  '\sum_{i=1}^4 rks_i*k_i
  Math scale k(),rks(i),a()
  Math c_add s(),a(),s()
  If i<(3+l) Then
   'y_{t} + dts_i * k_i
   Math scale k(),dts(i),k()
   Math c_add yt(),k(),k()
   t = t + dts(i)
  End If
 Next i

 'y_{t+dt} = y_{t} + \sum
 Math c_add yt(),s(),yt()
 rkstep=1
End Function

Sub rk4 fname$,y0(),t0,dt,o()
 'check bounds of arrays
 Local integer l = Bound(o(),0)
 Local integer n = Bound(o(),1)
 Local integer m = Bound(o(),2)

 If Bound(y0(),0) <> l Then
'I don't know if this is even possible
  Error "y0 and o must start at the same index"
 End If

 If Bound(y0(),1) <> n Then
  Error "array size mismatch"
 End If

 'initialize loop variables
 Local integer i,flag
 Local float yi(n)
 Local float ti = t0
 Array Add y0(),0,yi()
 Array Insert o(),,l,y0()

 'main loop
 For i=l+1 To m
  flag = rk4step(fname$,yi(),ti,dt)
  If flag=1 Then
   Print Format$(ti,"Integration terminated at t=%g")
   Exit For
  End If
  Array Insert o(),,i,yi()
  ti = ti + dt
 Next i
End Sub