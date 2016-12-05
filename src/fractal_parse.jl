# parses color specifications of form "0xRRGGBB" or "#RRGGBB" into colors to form a gradient
Base.parse(::Type{Gradient},startstr::AbstractString, endstr::AbstractString, nilstr::AbstractString) =
   Gradient(parse(RGB8bit,startstr),parse(RGB8bit,endstr),parse(RGB8bit,nilstr))
Base.parse(::Type{Gradient},str::AbstractString) =
	parse(Gradient,split(str)...)

# example: 0x7fa656 0x8bfd32 0x5fe995 (0.379184,-0.312113) zoom2.99581e-07 pow0.474523 affine0
function Base.parse(::Type{CameraSpec},specstr::AbstractString)
	spec=split(specstr)
	return CameraSpec(parse(Gradient,join(spec[1:3]," ")),parse_complex(spec[4]),
		parse_zoom(spec[5]),parse_pow(spec[6]),parse_affine(spec[7]))
end
# parses string "(re,im)" into a complex number Complex(re,im)
parse_complex(str::AbstractString)=Complex([parse(Float64,x) for x in split(str[2:end-1],",")]...)
# parses string "zoom1.2345" into a floating point number with everything after the 'zoom'
parse_zoom(str::AbstractString)=parse(Float64,str[5:end])
# parses string "pow1.2345" into a floating point number with everything after the 'pow'
parse_pow(str::AbstractString)=parse(Float64,str[4:end])
# parses string "affine0" into a boolean depending on whether the number after 'affine' is 0 or 1
parse_affine(str::AbstractString)=convert(Bool,parse(Int8,str[7]))
