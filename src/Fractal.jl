module Fractal

export Gradient,ImageSpec,CameraSpec,FractalSpec,FractalGenerator
include("fractal_types.jl")
include("fractal_parse.jl")
export fractal_names,create_fractal
include("fractal_variations.jl")
export generate_fractal
include("fractal_generate.jl")
include("fractal_core.jl")

end
