module VLBIPlots

using InterferometricModels
using Unitful
using IntervalSets
using DataPipes
using LinearAlgebra
using Accessors
using MakieExtra

# export plot_imageplane, BeamArtist
export RadPlot, ProjPlot, UVPlot

# include("artists.jl")
include("recipes.jl")

# proper_ustrip(::typeof(abs), x) = ustrip(x)
# proper_ustrip(::typeof(angle), x) = ustrip(u"°", x)


# function plot_imageplane(m::MultiComponentModel; colors=fill(:k, length(components(m))), kwargs...)
#     for (c, color) in zip(components(m), colors)
#         plot_imageplane(c; color, kwargs...)
#     end
# end

# function plot_imageplane(c::EllipticGaussian; color=:k, kwargs...)
#     plt.gca().add_patch(
#         matplotlib.patches.Ellipse(
#             coords(c); width=fwhm_min(c), height=fwhm_max(c), angle=-rad2deg(position_angle(c)),
#             fill=false, color, lw=0.5, kwargs...
#         )
#     )
# end

# function plot_imageplane(c::CircularGaussian; color=:k, kwargs...)
#     plt.gca().add_patch(
#         matplotlib.patches.Circle(
#             coords(c); radius=fwhm_max(c),
#             fill=false, color, lw=0.5, kwargs...
#         )
#     )
# end

end
