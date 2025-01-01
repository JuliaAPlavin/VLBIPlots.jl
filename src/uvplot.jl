@kwdef struct UVPlot{TD,UR}
    data::TD
    uvrange::UR = nothing
    uvscale = identity
end

UVPlot(uvtbl::AbstractVector; kwargs...) = UVPlot(; data=uvtbl, kwargs...)

Makie.convert_arguments(ct::PointBased, pp::UVPlot{<:AbstractVector}) =
    convert_arguments(ct, @p pp.data map(Point2(_uvfunc(pp.uvscale)(_uv(_))...)))

_uvfunc(uvscale) = function(uv)
    uv′ = @modify(uvscale, norm(uv))
    return inverse(uvscale).(uv′)
end

MakieExtra.@define_plotfunc (scatter, lines, scatterlines) UVPlot

MakieExtra.default_axis_attributes(::Any, pp::UVPlot; kwargs...) = (
    xlabel="U (λ)",
    ylabel="V (λ)",
    aspect=DataAspect(),
    autolimitaspect=1,
    xscale=pp.uvscale,
    yscale=pp.uvscale,
)
