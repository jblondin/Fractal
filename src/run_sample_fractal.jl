push!(LOAD_PATH,"./")
using Fractal
using Images

fspecstr="0x08e961 0xe08e96 0xbc11d2 (0.00709466,-0.664701) zoom9.23647e-06 pow0.561485 affine1"
filename="output.png"

camspec=parse(CameraSpec,fspecstr)
imagespec=ImageSpec(2^9,2^9,2)

fracspec=FractalSpec(create_fractal("mandelbrot"))
fracgen=FractalGenerator(camspec,imagespec,fracspec)
@time img=generate_fractal(fracgen)
save(filename,img)
