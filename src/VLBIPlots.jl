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

proper_ustrip(::typeof(abs), x) = ustrip(x)
proper_ustrip(::typeof(angle), x) = ustrip(u"°", x)

proper_label(::typeof(abs)) = "Amplitude (Jy)"
proper_label(::typeof(angle)) = "Phase (°)"

function radplot(func::Function, mod, c::AbstractVector{<:NamedTuple}; color=:red, kwargs...)
    uvdists = @p c |> map(norm(_.uv))
    vises = @p c |> map(proper_ustrip(func, func(visibility(mod, _.uv))))
    plt.xlim(auto=true)
    plt.ylim(auto=true)
    plt.scatter(uvdists, vises; s=0.1, color, kwargs...)
    plt.xlabel("UV distance (λ)")
    plt.ylabel(proper_label(func))
    plt.xlim(0)
    func == abs && plt.ylim(0)
    func == angle && lim_intersect(y=0 ± 180)
end

function radplot(func::Function, c::AbstractVector{<:NamedTuple}; color=:k, kwargs...)
    uvdists = @p c |> map(norm(_.uv))
    vises = @p c |> map(proper_ustrip(func, func(_.visibility)))
    plt.xlim(auto=true)
    plt.ylim(auto=true)
    plt.plot(uvdists, vises, ","; color, zorder=-1, kwargs...)  # zorder=1 is default for scatter, while zorder=2 for plot
    plt.xlabel("UV distance (λ)")
    plt.ylabel(proper_label(func))
    plt.xlim(0)
    func == abs && plt.ylim(0)
    func == angle && lim_intersect(y=0 ± 180)
end

function radplot(func::Function, c::ModelComponent, uvrng::AbstractInterval{<:Real}; n=100, alpha=0.2, color=nothing, kwargs...)
    uvdists = range(extrema(uvrng)...; length=n)
    vises = proper_ustrip.(func, visibility_envelope.(func, c, uvdists))
    color = @something(color, plt.gca()._get_lines.prop_cycler.__next__()["color"] |> mpl_color)
    plt.fill_between(uvdists, minimum.(vises), maximum.(vises); ec=color, fc=coloralpha(color, alpha), kwargs...)
    plt.xlabel("UV distance (λ)")
    plt.ylabel(proper_label(func))
    plt.xlim(extrema(uvrng)...)
    func == abs && plt.ylim(0)
    func == angle && lim_intersect(y=0 ± 180)
end

function radplot(funcs::Vector{<:Function}, args...; ax, kwargs...)
    @assert length(ax) == length(funcs)
    for (i, (a, f)) in zip(ax, funcs) |> enumerate
        plt.sca(a)
        radplot(f, args...; kwargs...)
    end
    for a in ax[begin+1:end-1]
        a.set_xlabel("")
    end
    if length(ax) > 1
        ax[1].xaxis.tick_top()
        ax[1].xaxis.set_label_position(:top)
    end
end

end
