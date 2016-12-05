using IfsFractal

@everywhere function draworbits(rng::MersenneTwister,pchunk_size::Int)
	canvas=IfsFractal.FractalCanvas(512,512,Complex(-0.5,0.0),0.25)
	for j=1:pchunk_size
		c=IfsFractal.randcomplex(rng)
		orbit=IfsFractal.mandelbrot(c)
		if orbit.escaped && length(orbit.zs) > 1
			IfsFractal.draw!(canvas,orbit)
		end
	end
	return canvas
end


function main2()
	rng=MersenneTwister(1)
	const num_orbits=100000
	const chunk_size=100000
	np=nprocs()
	canvases=Array{FractalCanvas,1}()
	# for p=1:np
	# 	push!(canvases,FractalCanvas(512,512,zero(Complex),0.25))
	# end
	rngs=randjump(rng,np)
	final_canvas=FractalCanvas(512,512,Complex(-0.5,0.0),0.25)

	for i=1:num_orbits/chunk_size
		# @time cs=[randcomplex(rng,2.0) for j=1:chunk_size]
		# start_cs_idx=1
		futures=Array{RemoteRef}(np)
		@time begin
		for p=1:np
			proc_chunk_size=trunc(Int,chunk_size/np)
			if p==np
				proc_chunk_size=chunk_size-((np-1)*proc_chunk_size)
			end
			futures[p]=@spawn draworbits(rngs[p],proc_chunk_size)
			# start_cs_idx+=proc_chunk_size
		end
		println("Spawned.")
		end
		@time begin
		for p=1:np
			push!(canvases,fetch(futures[p]))
			@show minimum(canvases[p].data),maximum(canvases[p].data),mean(canvases[p].data)
		end
		end
		# proc_chunk_size=trunc(Int,chunk_size/nprocs())
		# @time cs=[randcomplex(rng,2.0) for j=1:chunk_size]
		# future
		s=Array{RemoteRef}(nprocs())
		# @time begin
		# @everywhere function genorbits(pcs::Array{Complex{Float64}})
		# 	orbits=Array{IfsFractal.Orbit}(length(pcs))
		# 	for j=1:length(pcs)
		# 		orbits[j]=IfsFractal.mandelbrot(pcs[j])
		# 	end
		# 	orbits
		# end
		# start_cs_idx=1
		# for p=1:nprocs()
		# 	if p==nprocs()
		# 		proc_chunk_size=chunk_size-((nprocs()-1)*proc_chunk_size)
		# 	end
		# 	# @show typeof(cs[start_cs_idx:start_cs_idx+proc_chunk_size-1])
		# 	futures[p]=@spawnat p genorbits(cs[start_cs_idx:start_cs_idx+proc_chunk_size-1])
		# 	start_cs_idx+=proc_chunk_size
		# end
		# orbits=Array{Orbit,1}()
		# for p=1:nprocs()
		# 	porbits=fetch(futures[p])
		# 	# @show porbits
		# 	append!(orbits,porbits)
		# end
		# end
		# @show size(orbits)


		# orbits=Array{Orbit}(chunk_size)
		# orbit_ids=SharedArray(Int,chunk_size)
		# for j=1:chunk_size
		# 	orbit_ids[j]=j
		# end
		# @time cs=[randcomplex(rng,2.0) for j=1:chunk_size]
		# @time orbits=pmap(mandelbrot,cs)
		# @time begin
		# orbits=@sync @parallel (vcat) for j=1:chunk_size
		# 	mandelbrot(cs[j])
		# end
		# end
		# @time begin
		# for j=1:chunk_size
		# 	c=randcomplex(rng,2.0)
		# 	orbits[j]=mandelbrot(c,50000)
		# end
		# end
		# # @show orbits
		# @time begin
		# for j=1:chunk_size
		# 	if orbits[j].escaped
		# 		draw!(canvas,orbits[j])
		# 	end
		# end
		# end
		println("$(trunc(Int,i*chunk_size))/$num_orbits")
		for p=1:np
			# @show maximum(canvases[p].data),mean(canvases[p].data)
			final_canvas.data[:,:]+=canvases[p].data[:,:]
		end
	end
	# reduce
	f=open("canvas.dat","w")
	serialize(f,final_canvas)
	close(f)
	render(final_canvas,"out.4.png.bias0.05.png",0.05)
	render(final_canvas,"out.4.png.bias0.1.png",0.1)
	render(final_canvas,"out.4.png.bias0.2.png",0.2)
	render(final_canvas,"out.4.png.bias0.3.png",0.3)
end
main2()

using Colors
function main3()
	f=open("canvas.dat","r")
	canvas=deserialize(f)
	close(f)
	black=RGB{Float64}(0.0,0.0,0.0)
	white=RGB{Float64}(1.0,1.0,1.0)
	render(canvas,"out.4.png.bias0.05.png",0.05,black,white)
	render(canvas,"out.4.png.bias0.1.png",0.1,black,white)
	render(canvas,"out.4.png.bias0.2.png",0.2,black,white)
	render(canvas,"out.4.png.bias0.3.png",0.3,black,white)
end
# main3()
