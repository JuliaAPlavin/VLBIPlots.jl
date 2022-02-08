module VLBIPlots

export plot_imageplane, radplot, BeamArtist

using InterferometricModels
using Colors
using PyPlotUtils
using Unitful
using IntervalSets
using DataPipes
using LinearAlgebra

include("artists.jl")
include("radplot.jl")


function plot_imageplane(m::MultiComponentModel; colors=fill(:k, length(components(m))), kwargs...)
    for (c, color) in zip(components(m), colors)
        plot_imageplane(c; color, kwargs...)
    end
end

function plot_imageplane(c::EllipticGaussian; color=:k, kwargs...)
    plt.gca().add_patch(
        matplotlib.patches.Ellipse(
            coords(c); width=fwhm_min(c), height=fwhm_max(c), angle=-rad2deg(position_angle(c)),
            fill=false, color, lw=0.5, kwargs...
        )
    )
end

function plot_imageplane(c::CircularGaussian; color=:k, kwargs...)
    plt.gca().add_patch(
        matplotlib.patches.Circle(
            coords(c); radius=fwhm_max(c),
            fill=false, color, lw=0.5, kwargs...
        )
    )
end

end
