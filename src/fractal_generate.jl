using Images
using Iterators

#Base.call(Generator)=("Testing $(now())",["unittest1.png","unittest2.png"])
type FractalGenerator
   cameraspec::CameraSpec
   imagespec::ImageSpec
   fracspec::FractalSpec
end

function Base.call(fracgen::FractalGenerator)
   image_filename="temp.png"

   @time img=generate_fractal(fracgen)
   return ("Generated a fractal! $(now())",image_filename)
end

function generate_fractal(fracgen::FractalGenerator)
   w,h=fracgen.imagespec.width,fracgen.imagespec.height
   simgdata=SharedArray(RGB8bit,(w,h))
   # points=product(1:fracgen.imagespec.width,1:fracgen.imagespec.height)
   # @sync @parallel for point in points
   #    simgdata[point[1],point[2]]=JuliaFractal.get_pixel_color(fracgen,point[2],point[1])
   # end
   @sync @parallel for j in 1:w
      @inbounds @fastmath for i in 1:h
         simgdata[i,j]=get_pixel_color(fracgen,j,i)
      end
      # println("$j/$w")
   end
   # @sync @parallel for i in 1:w*h
   #    r=floor(Int,(i-1)/w)+1
   #    c=(i-1)%w+1
   #    simgdata[r,c]=get_pixel_color(fracgen,c,r)
   # end

   # imagedata=sdata(simgdata)
   imagedata=Array{RGB8bit}(w,h)
   imagedata[:,:]=sdata(simgdata)
   # # 1010 seconds
   # points=product(1:fracgen.imagespec.width,1:fracgen.imagespec.height)
   # getpixel=point->imagedata[point[1],point[2]]=get_pixel_color(fracgen,point[1],point[2])
   # pmap(getpixel,points)
   # 90 seconds in normal loop
   # for px in 1:fracgen.imagespec.width
   #    for py in 1:fracgen.imagespec.height
   #       imagedata[px,py]=get_pixel_color(fracgen,px,py)
   #    end
   # end
   return Image(imagedata)
end
