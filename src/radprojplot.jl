@kwdef struct RadPlot{D,M,F}
    uvdata::D
    model::M = nothing
    yfunc::F = abs
    nsteps::Int = 300
end

RadPlot(uvdata; kwargs...) = RadPlot(; uvdata, kwargs...)

Makie.convert_arguments(ct::PointBased, rp::RadPlot{<:AbstractVector,Nothing}) =
    convert_arguments(ct, @p rp.uvdata map(Point2(norm(_.uv), rp.yfunc(_.visibility))))
Makie.convert_arguments(ct::PointBased, rp::RadPlot{<:AbstractVector,<:Any}) =
    convert_arguments(ct, @p rp.uvdata map(Point2(norm(_.uv), visibility(rp.yfunc, rp.model, _.uv) |> ustrip)))

function Makie.convert_arguments(ct::Type{<:Band}, rp::RadPlot{<:AbstractInterval,<:Any})
    uvdists = range(rp.uvdata, length=rp.nsteps)
    vises = visibility_envelope.(rp.yfunc, rp.model, uvdists) .|> ustrip
    convert_arguments(ct, uvdists, minimum.(vises), maximum.(vises))
end

function Makie.convert_arguments(ct::PointBased, rp::RadPlot{<:AbstractInterval,<:Any})
    uvdists = range(rp.uvdata, length=rp.nsteps)
    vises = visibility_envelope.(rp.yfunc, rp.model, uvdists) .|> ustrip
    convert_arguments(ct, [uvdists; NaN; uvdists], [minimum.(vises); NaN; maximum.(vises)])
end

@kwdef struct ProjPlot{D,M,F,PA}
    uvdata::D
    model::M = nothing
    yfunc::F = abs
    posangle::PA
    nsteps::Int = 300
end

ProjPlot(uvdata, posangle; kwargs...) = ProjPlot(; uvdata, posangle, kwargs...)

function Makie.convert_arguments(ct::PointBased, pp::ProjPlot{<:AbstractVector,<:Nothing})
    uvec = sincos(pp.posangle)
    convert_arguments(ct, @p pp.uvdata map(Point2(dot(_.uv, uvec), pp.yfunc(_.visibility))))
end

function Makie.convert_arguments(ct::PointBased, pp::ProjPlot{<:AbstractVector,<:Any})
    uvec = sincos(pp.posangle)
    convert_arguments(ct, @p pp.uvdata map(Point2(dot(_.uv, uvec), visibility(pp.yfunc, pp.model, _.uv) |> ustrip)))
end

function Makie.convert_arguments(ct::PointBased, pp::ProjPlot{<:AbstractInterval,<:Any})
    uvdists = range(pp.uvdata, length=pp.nsteps)
    uvec = SVector(sincos(pp.posangle))
    vises = @p uvdists map(visibility(pp.yfunc, pp.model, _*uvec) |> ustrip)
    convert_arguments(ct, uvdists, vises)
end


MakieExtra.@define_plotfunc (scatter, lines, scatterlines, band) RadPlot
MakieExtra.@define_plotfunc (scatter, lines, scatterlines, band) ProjPlot

MakieExtra.default_axis_attributes(::Any, x::RadPlot; kwargs...) = (
    xlabel="UV distance (λ)",
    ylabel=Dict(abs => "Amplitude", angle => "Phase (rad)", rad2deg∘angle => "Phase (°)")[x.yfunc],
    limits=(_default_xlims(x), _default_ylims(x)),
)

MakieExtra.default_axis_attributes(::Any, x::ProjPlot; kwargs...) = (
    xlabel="UV projection (λ)",
    ylabel=Dict(abs => "Amplitude", angle => "Phase (rad)", rad2deg∘angle => "Phase (°)")[x.yfunc],
    limits=(_default_xlims(x), _default_ylims(x)),
)

_default_xlims(rp::RadPlot{<:AbstractVector}) = @p rp.uvdata maximum(norm(_.uv)) 1.05*__ (0, __)
_default_xlims(rp::RadPlot{<:AbstractInterval}) = extrema(rp.uvdata)

_default_xlims(rp::ProjPlot{<:AbstractVector}) = @p rp.uvdata maximum(norm(_.uv)) 1.05*__ (0, __)
_default_xlims(rp::ProjPlot{<:AbstractInterval}) = extrema(rp.uvdata)

_default_ylims(x::Union{RadPlot,ProjPlot}) = get(Dict(
    abs => (0, nothing),
    # angle => (-π, π),
    # rad2deg∘angle => (-180, 180)
), x.yfunc, nothing)
