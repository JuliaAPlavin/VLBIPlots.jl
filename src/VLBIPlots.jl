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
using VLBIData


export RadPlot, ProjPlot, UVPlot, beampoly!

# for convenient overrides:
_visibility(x::NamedTuple) = @oget x.visibility x.value

_ustrip_i(x::Interval) = @modify(ustrip, endpoints(x)[∗])

module AxFuncs
using ..Accessors, ..InverseFunctions, ..LinearAlgebra, ..VLBIData, ..MakieExtra, Dates
import .._visibility, ..@p
include("axfuncs.jl")
end
include("radprojplot.jl")
include("uvplot.jl")
include("beamplot.jl")
include("modelimage.jl")
include("modelpoly.jl")

end
