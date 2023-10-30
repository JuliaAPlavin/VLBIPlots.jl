proper_ustrip(::typeof(abs), x) = ustrip(x)
proper_ustrip(::typeof(angle), x) = ustrip(u"°", x)

proper_label(::typeof(abs)) = "Amplitude (Jy)"
proper_label(::typeof(angle)) = "Phase (°)"

function radplot(func::Function, mod, c::AbstractVector{<:NamedTuple}; color=:red, kwargs...)
    uvs = @p c |> mapview(@optic _.uv)
    uvdists = norm.(uvs)
    vises = proper_ustrip.(func, visibility.(func, mod, uvs))
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

    l, = plt.plot([], [])
    color = @something(color, l.get_color() |> mpl_color)

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
