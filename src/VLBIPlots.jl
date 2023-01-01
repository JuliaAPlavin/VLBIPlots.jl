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


function plot_imageplane(m::MultiComponentModel; kwargs...)
    for c in components(m)
        plot_imageplane(c; kwargs...)
    end
end

function plot_imageplane(c::EllipticGaussian)
    plt.gca().add_patch(
        matplotlib.patches.Ellipse(
            coords(c), width=fwhm_min(c), height=fwhm_max(c), angle=-rad2deg(position_angle(c)),
            fill=false, color=:k, lw=0.5
        )
    )
end

function plot_imageplane(c::CircularGaussian)
    plt.gca().add_patch(
        matplotlib.patches.Circle(
            coords(c), radius=fwhm_max(c),
            fill=false, color=:k, lw=0.5
        )
    )
end

end
