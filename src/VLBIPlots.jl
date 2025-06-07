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

_ustrip_i(x::Interval) = @modify(ustrip, endpoints(x)[∗])

module AxFuncs
using Accessors, InverseFunctions, LinearAlgebra, VLBIData, InterferometricModels, MakieExtra, Dates, Unitful
import ..@p
include("axfuncs.jl")
end
const F = AxFuncs
include("radprojplot.jl")
include("uvplot.jl")
include("beamplot.jl")
include("modelimage.jl")
include("modelpoly.jl")

end
