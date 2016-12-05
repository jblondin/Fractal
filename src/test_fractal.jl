push!(LOAD_PATH,"./")
using Fractal
using Images

# fspecstr="0x5c82f6 0x720bd8 0x417b14 (0.303251,-0.0213448) zoom2.08799e-05 pow0.79505 affine1"
fspecstr="0x9f8f41 0x3f1e83 0xd3f1e8 (0.0,0.0) zoom3.0 pow0.79505 affine1"
camspec=parse(CameraSpec,fspecstr)
imagespec=ImageSpec(2^9,2^9,2)
for fracname in fractal_names()
	println("Generating $fracname...")
	filename="test_$(fracname).png"
	if isfile(filename)
		continue
	end
	fracspec=FractalSpec(create_fractal(fracname))
	fracgen=FractalGenerator(camspec,imagespec,fracspec)
	@time img=generate_fractal(fracgen)
	save(filename,img)
end
