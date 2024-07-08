Makie.used_attributes(::Type{<:Image}, m::Union{ModelComponent, MultiComponentModel}) = (:npix,)
Makie.used_attributes(::Type{<:Image}, x::ClosedInterval, y::ClosedInterval, m::Union{ModelComponent, MultiComponentModel}) = (:npix,)

Makie.convert_arguments(
	ct::ImageLike,
    model::Union{ModelComponent, MultiComponentModel};
	npix=256,
) = Makie.convert_arguments(ct, _default_xyintervals(model)..., model; npix)

Makie.convert_arguments(
	ct::ImageLike,
    x::ClosedInterval,
    y::ClosedInterval,
    model::Union{ModelComponent, MultiComponentModel};
	npix=256,
) = Makie.convert_arguments(ct, range(x, length=npix), range(y, length=npix), model)

Makie.convert_arguments(
	ct::ImageLike,
    x::AbstractVector,
    y::AbstractVector,
    model::Union{ModelComponent, MultiComponentModel}
) = Makie.convert_arguments(ct, grid(SVector, x, y), model)

Makie.convert_arguments(
	ct::ImageLike,
    xy::AbstractMatrix,
    model::Union{ModelComponent, MultiComponentModel}
) = Makie.convert_arguments(ct, intensity(model).(xy))

function _default_xyintervals(model::ModelComponent)
    c = coords(model)
    w = fwhm_max(model)
    Tuple(c .± 3w)
end

function _default_xyintervals(model::MultiComponentModel)
    intpairs = map(_default_xyintervals, components(model))
    ex1 = @p intpairs flatmap(extrema(_[1])) extrema
    ex2 = @p intpairs flatmap(extrema(_[2])) extrema
    wmax = max(ex1[2] - ex1[1], ex2[2] - ex2[1])
    avgs = mean.((ex1, ex2))
    avgs .± wmax/2
end

_rngs_from_intervals(int::AbstractInterval, npix) = (reverse(range(int, npix)), range(int, npix))
_rngs_from_intervals(ints::NTuple{2,AbstractInterval}, npix::Int) = (reverse(range(ints[1], npix)), range(ints[2], npix))

_xyranges(x::AbstractArray) = (x, x)
_xyranges(x::Tuple) = x
