/*
  Double Pendulum

A double pendulum implementation, uses 
RK4 to integrate each time step, which 
requires that the user have loaded 
rk4.bas into the library using 
LIBRARY SAVE prior to running this.

The initial conditions and system
parameters start after the function
and subroutine definitions.

*/

option angle radians
option base 1
framebuffer create
framebuffer write f
cls rgb(black)

'system of equations dy/dt=rhs(t,y)
function rhs(t,y(),dy()) as integer
 local float o1=y(1) '\theta_1
 local float w1=y(2) '\omega_1
 local float o2=y(3) '\theta_2
 local float w2=y(4) '\omega_2

 local float del=o2-o1
 local float den=(m1+m2)-m2*cos(del)^2
 dy(1)=y(2) '\dot{\theta_1} = \omega_1
 dy(2)=((m2*l1*w1^2)*sin(del)*cos(del)+ m2*g*sin(o2)*cos(del)+ m2*l2*w2^2*sin(del)- (m1+m2)*g*sin(o1))/(l1*den)
 dy(3)=y(4)
 dy(4)=(-m2*l2*w2^2*sin(del)*cos(del)+ (m1+m2)*(g*sin(o1)*cos(del)- l1*w1^2*sin(del) - g*sin(o2)))/(l2*den)

 rhs = 1
end function

sub plot_pen x1,y1,x2,y2
 static integer h  = MM.VRES
 static integer w  = MM.HRES
 static integer xo = w\2
 static integer yo = h\2
 static float scl = h/2/(l1+l2)
 static float rad = 10/(m1+m2)
 static integer r1 = fix(m1*rad)
 static integer r2 = fix(m2*rad)
 local integer px1 = fix(x1*scl)+xo
 local integer py1 = yo-fix(y1*scl)
 local integer px2 = fix(x2*scl)+xo
 local integer py2 = yo-fix(y2*scl)

 cls rgb(black)
 line xo,yo,px1,py1,1,rgb(green)
 circle px1,py1,r1,1,,rgb(blue),-1
 line px1,py1,px2,py2,1,rgb(green)
 circle px2,py2,r2,1,,rgb(blue),-1
 framebuffer copy f,n
end sub

'system parameters
dim float g  = 9.81'm/s^2
dim float l1 = 1.0 'm
dim float m1 = 1.0 'kg
dim float l2 = 1.0 'm
dim float m2 = 1.0 'kg

'initial conditions and integration
dim float dt=0.05
dim float y(4) = (pi/2,0,pi/2,0)
dim float th1,th2,x1,y1,x2,y2
dim integer f,i
do
 f   = rk4step("rhs",y(),0,dt)
 th1 = y(1)
 x1  = l1*sin(th1)
 y1  = -l1*cos(th1)
 th2 = y(3)
 x2  = x1+l2*sin(th2)
 y2  = y1-l2*cos(th2)
 plot_pen x1,y1,x2,y2
loop
