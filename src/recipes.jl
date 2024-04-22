@kwdef struct RadPlot{D,M,F}
    uvdata::D
    model::M = nothing
    yfunc::F = abs
end

RadPlot(uvdata; kwargs...) = RadPlot(; uvdata, kwargs...)

Makie.convert_arguments(ct::PointBased, rp::RadPlot{<:AbstractVector,Nothing}) =
    Makie.convert_arguments(ct, @p rp.uvdata map(Point2(norm(_.uv), rp.yfunc(_.visibility))))
Makie.convert_arguments(ct::PointBased, rp::RadPlot{<:AbstractVector,<:Any}) =
    Makie.convert_arguments(ct, @p rp.uvdata map(Point2(norm(_.uv), visibility(rp.yfunc, rp.model, _.uv))))

function Makie.convert_arguments(ct::Type{<:Band}, rp::RadPlot{<:AbstractInterval,<:Any})
    uvdists = range(rp.uvdata, length=300)
    vises = visibility_envelope.(rp.yfunc, rp.model, uvdists)
    Makie.convert_arguments(ct, uvdists, minimum.(vises), maximum.(vises))
end


@kwdef struct ProjPlot{D,M,F,PA}
    uvdata::D
    model::M = nothing
    yfunc::F = abs
    posangle::PA
end

ProjPlot(uvdata::AbstractVector, posangle; kwargs...) = ProjPlot(; uvdata, posangle, kwargs...)

function Makie.convert_arguments(ct::PointBased, pp::ProjPlot{<:AbstractVector,<:Nothing})
    uvec = sincos(pp.posangle)
    Makie.convert_arguments(ct, @p pp.uvdata map(Point2(dot(_.uv, uvec), pp.yfunc(_.visibility))))
end

function Makie.convert_arguments(ct::PointBased, pp::ProjPlot{<:AbstractVector,<:Any})
    uvec = sincos(pp.posangle)
    Makie.convert_arguments(ct, @p pp.uvdata map(Point2(dot(_.uv, uvec), visibility(pp.yfunc, pp.model, _.uv))))
end


MakieExtra.@define_plotfunc (scatter, band) RadPlot
MakieExtra.@define_plotfunc (scatter, band) ProjPlot

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

_default_xlims(rp::RadPlot{<:AbstractVector}) = (0, nothing)
_default_xlims(rp::RadPlot{<:AbstractInterval}) = extrema(rp.uvdata)

_default_xlims(rp::ProjPlot{<:AbstractVector}) = @p rp.uvdata maximum(norm(_.uv)) (-__, __)

_default_ylims(x::Union{RadPlot,ProjPlot}) = get(Dict(
    abs => (0, nothing),
    # angle => (-π, π),
    # rad2deg∘angle => (-180, 180)
), x.yfunc, nothing)


@kwdef struct UVPlot{TD,UR}
    data::TD
    uvrange::UR = nothing
end

UVPlot(uvtbl::AbstractVector) = UVPlot(; data=uvtbl)

Makie.convert_arguments(ct::PointBased, pp::UVPlot{<:AbstractVector}) =
    Makie.convert_arguments(ct, @p pp.data map(Point2(_.uv...)))

MakieExtra.@define_plotfunc (scatter,) UVPlot

MakieExtra.default_axis_attributes(::Any, x::UVPlot; kwargs...) = (
    xlabel="U (λ)",
    ylabel="V (λ)",
    aspect=DataAspect(),
    autolimitaspect=1,
)
