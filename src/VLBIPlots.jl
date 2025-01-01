module VLBIPlots

using InterferometricModels
using Unitful
using IntervalSets
using LinearAlgebra
using InverseFunctions
using Accessors
using AccessorsExtra: @oget, @maybe
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

# for convenient overrides:
_uv(x::NamedTuple) = @oget x.uv x.spec.uv
_visibility(x::NamedTuple) = @oget x.visibility x.value

end
