@kwdef struct UVPlot{TD,UR}
    data::TD
    uvrange::UR = nothing
end

UVPlot(uvtbl::AbstractVector) = UVPlot(; data=uvtbl)

Makie.convert_arguments(ct::PointBased, pp::UVPlot{<:AbstractVector}) =
    convert_arguments(ct, @p pp.data map(Point2(_.uv...)))

MakieExtra.@define_plotfunc (scatter,) UVPlot

MakieExtra.default_axis_attributes(::Any, x::UVPlot; kwargs...) = (
    xlabel="U (λ)",
    ylabel="V (λ)",
    aspect=DataAspect(),
    autolimitaspect=1,
)
