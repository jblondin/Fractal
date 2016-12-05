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
fractal specification (from @fractweet) and the output filename:
```julia
fspecstr="0x08e961 0xe08e96 0xbc11d2 (0.00709466,-0.664701) zoom9.23647e-06 pow0.561485 affine1"
filename="output.png"
```
For example, this specification string will regenerate the image in
[this tweet](https://twitter.com/fractweet/status/805351411680772096).

Then run with `julia -p <num CPUs> run_sample_fractal.jl` in the 'src' directory.

There's also some code in here to generate buddhabrots / nebulabrots, but it doesn't fully work.

## Known bugs
* For tigher zoom levels (lower values, ~1.0e-08 or less), there is a lack of precision in the
center specification and you may not be in the correct position to regenerate the exact image
specified. This is a bug in @fractweet itself, not a limitation of this program.
