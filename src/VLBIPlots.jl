module VLBIPlots

using InterferometricModels
using Unitful
using IntervalSets
using LinearAlgebra
using Accessors
using MakieExtra
using MakieExtra: Makie, Makie.GeometryBasics
using DataManipulation: @p, flatmap, uniqueonly
using Statistics: mean
using RectiGrids
using AxisKeysExtra
using StaticArrays: SVector


export RadPlot, ProjPlot, UVPlot, beampoly!

include("radprojplot.jl")
include("uvplot.jl")
include("beamplot.jl")
include("modelimage.jl")
include("modelpoly.jl")

# proper_ustrip(::typeof(abs), x) = ustrip(x)
# proper_ustrip(::typeof(angle), x) = ustrip(u"°", x)

end
