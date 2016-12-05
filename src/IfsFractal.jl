module IfsFractal

export FractalCanvas,Orbit
export randcomplex,mandelbrot,draw!,render

using Images
using Colors

@inline function randcomplex(rng::MersenneTwister,maxnorm::Float64=2.0)
	c=Complex(maxnorm*(rand(rng)*2-1),maxnorm*(rand(rng)*2-1))
	while distsqrd(c,zero(Complex)) > maxnorm*maxnorm
		c=Complex(maxnorm*(rand(rng)*2-1),maxnorm*(rand(rng)*2-1))
	end
	return c
end
type Pixel
	x::Int
	y::Int
end
type FractalCanvas
	width::Int
	height::Int
	center::Complex
	zoom::Float64
	data::Matrix{Float64}
end
FractalCanvas(width::Int,height::Int,center::Complex,zoom::Float64) =
	FractalCanvas(width,height,center,zoom,zeros(Float64,height,width))

@inline project(canvas::FractalCanvas,pnt::Complex) =
	Pixel(round(Int,((real(pnt)-real(canvas.center))*canvas.zoom+0.5)*canvas.width),
		round(Int,((imag(pnt)-imag(canvas.center))*canvas.zoom+0.5)*canvas.height))
@inline inbounds(canvas::FractalCanvas,pixel::Pixel) =
	pixel.x>=1 && pixel.x <=canvas.width && pixel.y >= 1 && pixel.y <= canvas.height

function writepixel!(canvas::FractalCanvas,pixel::Pixel)
	if inbounds(canvas,pixel)
		canvas.data[pixel.y,pixel.x]+=1.0
	end
end

type SamplerData
	cs::Vector{Complex}
	contribs::Vector{Float64}
end
SamplerData()=SamplerData(Vector{Complex}(),Vector{Float64}())
function add!(sd::SamplerData,c::Complex,contrib::Float64)
	push!(sd.cs,c)
	push!(sd.contribs,contrib)
end

type Orbit
	c::Complex
	zs::Vector{Complex}
	escaped::Bool
end
Orbit(c::Complex)=Orbit(c,Vector{Complex}(),false)
const MAX_ORBIT_LENGTH=50000
const DEFAULT_NUM_MANDELBROT_ITERS=200
@inline function mandelbrot(c::Complex,num_iters::Int=DEFAULT_NUM_MANDELBROT_ITERS)
	z=zero(Complex)
	orbit=Orbit(c)
	# const threshold=2^16
	const threshold=4
	for i=1:num_iters
		z=z*z+orbit.c
		push!(orbit.zs,z)
		if real(z*z') > threshold
			orbit.escaped=true
			return orbit
		end
		if length(orbit.zs) >= MAX_ORBIT_LENGTH
			break
		end
	end
	return orbit
end

@inline function contrib(canvas::FractalCanvas,orbit::Orbit)
	ctrib=0
	for i=1:length(orbit.zs)
		pixel=project(canvas,orbit.zs[i])
		if inbounds(canvas,pixel)
			ctrib+=1
		end
	end
	return ctrib/length(orbit.zs)
end

function generate_sample_points(rng::MersenneTwister,canvas::FractalCanvas)
	const num_samplers=30
	const num_sampling_iters=50000
	samplerdata=SamplerData()
	for i=1:num_samplers
		c=find_initial_point(rng,canvas,Complex(0.0,0.0),2.0)
		if isinf(c)
			warn("Unable to find initial poitn for sampler $i")
			continue
		end
		mandelbrot(c,num_sampling_iters)
		cont=contrib(canvas,orbit)
		add!(samplerdata,c,cont)
	end
	return samplerdata
end

distsqrd(c1::Complex,c2::Complex)=(real(c2)-real(c1))*(real(c2)-real(c1))+
	(imag(c2)-imag(c1))*(imag(c2)-imag(c1))

function find_initial_point(rng::MersenneTwister,canvas::FractalCanvas,pnt::Complex,radius::Float64,
		depth::Int=0)
	const num_search_attempts=200
	const num_search_iters=50000
	const max_depth=500
	if depth > max_depth
		return Complex(Inf,Inf)
	end
	closest=Inf
	nextseed=pnt
	for i=1:num_search_attempts
		c=randcomplex(rng,radius)+pnt
		orbit=mandelbrot(c,num_search_iters)
		if !orbit.escaped
			continue
		end
		contribution=contrib(canvas,orbit)
		if contribution > 0.0
			return c
		end
		for j=1:length(orbit.zs)
			ds=distsqrd(orbit.zs[j],canvas.center)
			if ds < closest
				closest=ds
				nextseed=c
			end
		end
	end
	return find_initial_point(rng,canvas,nextseed,radius/2.0,depth+1)
end

function burnin!(canvas::FractalCanvas,samplerdata::SamplerData)
	for i=1:length(samplerdata.cs)
		const warmup_length=10000
		for j=1:warmup_length
		end
	end
end

function loop!(canvas::FractalCanvas)
end

function main()
	rng=MersenneTwister(1)
	canvas=FractalCanvas(512,512,zero(Complex),0.25)
	samplerdata=generate_sample_points(rng,canvas)
	burnin!(canvas,samplerdata)
	loop!(canvas)
	f=open("canvas.metro.dat","w")
	serialize(f,canvas)
	close(f)
	render(canvas,"out.metro.dat")
end


function draw!(canvas::FractalCanvas,orbit::Orbit)
	for z in orbit.zs
		px=project(canvas,z)
		# @show orbit.zs[i],px,inbounds(canvas,px)
		writepixel!(canvas,px)
	end
end

const DEFAULT_GAIN_COEF=0.2
@inline compute_bias_coef(gain_coef::Float64)=log(1.0-gain_coef)/log(0.5)
@inline bias(val::Float64,bias_coef::Float64) = val>0.0 ? val^bias_coef : 0.0
@inline gain(val::Float64,bias_coef::Float64) =
	0.5*(val<0.5 ? bias(2.0*val,bias_coef) : 2.0-bias(2.0-2.0*val,bias_coef))
@inline clamp01(val::Float64) = clamp(val,0.0,1.0)

function compute_pixels!(imagedata::Matrix{RGB{Float64}},canvas::FractalCanvas,
		gain_coef::Float64,bgcolor::RGB{Float64},fgcolor::RGB{Float64})
	maxval=maximum(canvas.data)
	minval=minimum(canvas.data)
	@show maxval,minval,mean(canvas.data)
	bias_coef=compute_bias_coef(gain_coef)
	for j=1:canvas.width
		for i=1:canvas.height
			# pixel=clamp01(gain(canvas.data[i,j]/maxval,bias_coef)*2.0)
			pixel=clamp01(2.0*(canvas.data[i,j]-minval)/(maxval-minval))^0.5
			imagedata[i,j]=RGB{Float64}(
				(1.0-pixel)*bgcolor.r+pixel*fgcolor.r,
				(1.0-pixel)*bgcolor.g+pixel*fgcolor.g,
				(1.0-pixel)*bgcolor.b+pixel*fgcolor.b)
		end
	end
end
function render(canvas::FractalCanvas,filename::AbstractString,
		gain_coef::Float64=DEFAULT_GAIN_COEF,
		bgcolor::RGB{Float64}=RGB{Float64}(1.0,1.0,1.0),
		fgcolor::RGB{Float64}=RGB{Float64}(0.0,0.0,0.0))
	# @show canvas.data
	imagedata=fill(bgcolor,(canvas.height,canvas.width))
	compute_pixels!(imagedata,canvas,gain_coef,bgcolor,fgcolor)
	img=Image(imagedata)
	save(filename,img)
end

end
