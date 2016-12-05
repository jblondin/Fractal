# NUM_MAX_ITERATIONS=100000
NUM_MAX_ITERATIONS=10000

function get_pixel_color(fracgen::FractalGenerator,px::Int64,py::Int64)
   r=0.0
   g=0.0
   b=0.0

   for i in 1:fracgen.imagespec.num_supersamples
      dx=Float64(i-1)/fracgen.imagespec.num_supersamples
      x=((Float64(px)+dx)/fracgen.imagespec.width-0.5)*fracgen.cameraspec.zoom+
         fracgen.cameraspec.center.re

      for j in 1:fracgen.imagespec.num_supersamples
         dy=Float64(j-1)/fracgen.imagespec.num_supersamples
         y=((Float64(py)+dy)/fracgen.imagespec.height-0.5)*fracgen.cameraspec.zoom+
            fracgen.cameraspec.center.im
         prop=get_num_iters(fracgen.fracspec.fracfunc_closure(Complex(x,y))...)
         if fracgen.cameraspec.affine
            prop=max(0.0,prop)
         else
            prop=max(0.0,prop/NUM_MAX_ITERATIONS)
         end
         prop=prop^fracgen.cameraspec.pow
         color=blend(fracgen.cameraspec.gradient,prop)
         r+=color.r
         g+=color.g
         b+=color.b
      end
   end

   nss=fracgen.imagespec.num_supersamples*fracgen.imagespec.num_supersamples
   r/=nss
   g/=nss
   b/=nss
   return RGB8bit(r,g,b)
end


function get_num_iters(f::Function,zinit::Complex=zero(Complex))
   i=0
   THRESHOLD=2^16
   z=zinit
   while i < NUM_MAX_ITERATIONS
      # tempreal=zx
      # zx=zx*zx-zy*zy-cx
      # zy=2*tempreal*zy-cy
      z=f(z)
      if real(z*z') >= THRESHOLD
         break
      end
      i+=1
   end
   if i==NUM_MAX_ITERATIONS
      return 0.0
   end
   i=Float64(i)
   i+=(1.0-log2(log2(real(z*z'))/2.0))
   return i
end
# get_num_iters(x::Float64,y::Float64)=julia(x,y,0.0,0.0)

# inverse plane
# 1/(a+b*i) = (a-b*i)/(a^2+b^2)
# @inline function get_num_iters(c::Complex)
#    # xysqrd=x*x+y*y
#    julia(zero(Complex),1.0/c-0.25)
# end
# @inline function get_num_iters(c::Complex)
#    get_num_iters_inverse(c+0.25)
# end
# function julia(z::Complex,c::Complex)
#    i=0
#    THRESHOLD=2^16
#    while i < NUM_MAX_ITERATIONS
#       # tempreal=zx
#       # zx=zx*zx-zy*zy-cx
#       # zy=2*tempreal*zy-cy
#       z=z*z-c
#       if real(z*z') >= THRESHOLD
#          break
#       end
#       i+=1
#    end
#    if i==NUM_MAX_ITERATIONS
#       return 0.0
#    end
#    i=Float64(i)
#    i+=(1.0-log2(log2(real(z*z'))/2.0))
#    return i
# end
function blend(gradient::Gradient,prop::Float64)
   if prop == 0.0
      return gradient.nilcolor
   end
   return blend(gradient.startcolor,gradient.endcolor,prop)
end
function blend(startcolor::RGB8bit,endcolor::RGB8bit,prop::Float64)
   bl=(s,e,p)->p*s+e*(1.0-p) # blend between s and e
   function blnd(s,e,p)
      # have color values over 1.0 wrap around
      o=bl(s,e,p)%1.0
      return o > 0 ? o : 1.0+o
   end
   return RGB8bit(
      blnd(startcolor.r,endcolor.r,prop),
      blnd(startcolor.g,endcolor.g,prop),
      blnd(startcolor.b,endcolor.b,prop))
end
