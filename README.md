# Fractal

Fractal generator written in Julia.  Very rough / unsupported / semi-abandoned.

Tested in Julia 0.4.5. It may work in more recent versions, but this hasn't been confirmed.

Required packages (list may not be complete?):
* Colors
* FixedPointNumbers
* Iterators
* ColorTypes
* Images
* ColorVectorSpace
* FileIO
* StatsBase
* Graphics
* ImageMagick

See 'src/run_sample_fractal.jl' for a simle fractal example. Update these lines to change the
fractal specification (from @fractweet), output filename, width, height, and supersampling:
```julia
fspecstr="0x08e961 0xe08e96 0xbc11d2 (0.00709466,-0.664701) zoom9.23647e-06 pow0.561485 affine1"
filename="output.png"
width=4096
height=4096
num_supersamples=2
```
For example, this specification string will regenerate the image in
[this tweet](https://twitter.com/fractweet/status/805351411680772096) at 4096x4096 resolution,
with 2x supersampling per dimension, and save it to 'output.png'.

The `num_supersamples` option denotes how many samples in each dimension (width and height) that
are taken for each pixel. Thus, a `num_supersamples` of `2` ends up meaning 2*2=4 samples per
pixel. Therefore, the specification above will actually sample 8192x8192 while generating this
image.

Once you've made the necessary specifications, run with `julia -p <num CPUs> run_sample_fractal.jl`
in the 'src' directory.

It's going to take a few minutes, even with several CPUs. It's pretty slow and unoptimized; I'm not
that good at Julia performance (the C++ version that's behind @fractweet is faster, even on a micro
Amazon instance). It took ~380 seconds on my computer to test the image in run_sample_fractal.jl,
even with 8 CPU cores.

There's also some code in here to generate buddhabrots / nebulabrots, but it doesn't fully work.

## Known bugs
* For tigher zoom levels (lower values, ~1.0e-08 or less), there is a lack of precision in the
center specification and you may not be in the correct position to regenerate the exact image
specified. This is a bug in @fractweet itself, not a limitation of this program.
