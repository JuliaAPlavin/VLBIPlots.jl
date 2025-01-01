MakieExtra.@define_plotfunc (poly,) Union{ModelComponent,MultiComponentModel}
MakieExtra.@define_plotfunc (scatter,) Union{ModelComponent,MultiComponentModel}

Makie.convert_arguments(ct::Type{<:Poly}, m::InterferometricModels.Point) =
    convert_arguments(ct, Circle(Point2(ustrip.(coords(m))...), 0))

Makie.convert_arguments(ct::Type{<:Poly}, m::CircularGaussian) =
    convert_arguments(ct, Circle(Point2(ustrip.(coords(m))...), ustrip(fwhm_average(m) / 2)))

function Makie.convert_arguments(ct::Type{<:Poly}, m::EllipticGaussian)
    s, c = sincos(π/2 - position_angle(m))
    trmat = [c -s; s c] * Diagonal([fwhm_max(m), fwhm_min(m)] / 2)
    polygon = map(range(0, 2π, length=100)) do θ
        p_circ = SVector(sincos(θ))
        Point2(ustrip.(trmat * p_circ + coords(m))...)
    end |> GeometryBasics.Polygon
    convert_arguments(ct, polygon)
end

Makie.convert_arguments(ct::Type{<:Poly}, m::EllipticGaussianCovmat) = convert_arguments(ct, EllipticGaussian(m))

Makie.convert_arguments(ct::PointBased, m::ModelComponent) = convert_arguments(ct, Point2(ustrip(coords(m))...))

Makie.convert_arguments(ct::Type{<:Poly}, m::MultiComponentModel) =
    (map(components(m)) do c
        convert_arguments(ct, c) |> only
    end |> collect |> Vector{Makie.PolyElements},)

Makie.convert_arguments(ct::PointBased, m::MultiComponentModel) =
    (flatmap(components(m)) do c
        convert_arguments(ct, c) |> only
    end,)


_flux_unit(m::ModelComponent) = unit(flux(m))
_flux_unit(m::MultiComponentModel) = map(_flux_unit, components(m)) |> uniqueonly
_coord_unit(m::ModelComponent) = [unit(coords(m)[1]), unit(sqrt(effective_area(m)))] |> uniqueonly
_coord_unit(m::MultiComponentModel) = map(_coord_unit, components(m)) |> uniqueonly

function MakieExtra.default_axis_attributes(::Union{Type{<:Poly},Type{<:Scatter}}, m::Union{ModelComponent,MultiComponentModel}; kwargs...)
    u = _coord_unit(m)
    (
        aspect=DataAspect(),
        xlabel="($u)", ylabel="($u)",
        xreversed=true,
    )
end
