using Colors
using FixedPointNumbers

typealias RGB8bit ColorTypes.RGB{FixedPointNumbers.UFixed{UInt8,8}}

type Gradient
   startcolor::RGB8bit
   endcolor::RGB8bit
   nilcolor::RGB8bit
end

type ImageSpec
   width::Int64
   height::Int64
   num_supersamples::Int64
end

type CameraSpec
   gradient::Gradient
   center::Complex
   zoom::Float64
   pow::Float64
   affine::Bool
end

type FractalSpec
   fracfunc_closure::Function
end
