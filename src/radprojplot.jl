RadPlot(fplt::FPlot; yfunc=abs, uvscale=identity, model=nothing, kwargs...) = @p let
	fplt
	@insert __[1] = norm ∘ VLBI.UV
	@insert __[2] = isnothing(model) ?
						yfunc ∘ _visibility :
						(@o visibility(yfunc, model, VLBI.UV(_)) |> ustrip)
	@set __.axis = (;
		xlabel="UV distance (λ)",
		ylabel=_ylabel_by_func(yfunc),
		limits=(
			(@p fplt.data maximum(norm(VLBI.UV(_))) (-0.02*__, 1.05*__)),
			_ylims_by_func(yfunc),
		),
		to_x_attrs((scale=uvscale, tickformat=EngTicks(:symbol)))...,
		fplt.axis...,
		get(kwargs, :axis, (;))...,
	)
	setproperties(__, delete(NamedTuple(kwargs), (@maybe _.axis)))
end

RadPlot(tbl::AbstractVector; yfunc=abs, uvscale=identity, model=nothing, kwargs...) = RadPlot(FPlot(tbl); yfunc, uvscale, model, kwargs...)

RadPlot(uvs::AbstractInterval; yfunc=abs, uvscale=identity, model=nothing, kwargs...) =
	FPlot((),
		Ref(uvs),
		Ref(@o visibility_envelope(yfunc, model, _) |> ustrip);
		axis=(;
			xlabel="UV distance (λ)",
			ylabel=_ylabel_by_func(yfunc),
			limits=(
				extrema(uvs),
				_ylims_by_func(yfunc),
			),
			to_x_attrs((scale=uvscale, tickformat=EngTicks(:symbol)))...,
			get(kwargs, :axis, (;))...,
		),
		delete(NamedTuple(kwargs), (@maybe _.axis))...,
	)


ProjPlot(fplt::FPlot, posangle; yfunc=abs, uvscale=identity, model=nothing, kwargs...) = @p let
	fplt
	@insert __[1] = @o dot(VLBI.UV(_), sincos(posangle))
	@insert __[2] = isnothing(model) ?
						yfunc ∘ _visibility :
						(@o visibility(yfunc, model, VLBI.UV(_)) |> ustrip)
	@set __.axis = (;
		xlabel="UV projection (λ)",
		ylabel=_ylabel_by_func(yfunc),
		limits=(
			(@p fplt.data maximum(norm(VLBI.UV(_))) (-0.02*__, 1.05*__)),
			_ylims_by_func(yfunc),
		),
		to_x_attrs((scale=uvscale, tickformat=EngTicks(:symbol)))...,
		fplt.axis...,
		get(kwargs, :axis, (;))...,
	)
	setproperties(__, delete(NamedTuple(kwargs), (@maybe _.axis)))
end

ProjPlot(tbl::AbstractVector, posangle; yfunc=abs, uvscale=identity, model=nothing, kwargs...) = ProjPlot(FPlot(tbl), posangle; yfunc, uvscale, model, kwargs...)

ProjPlot(uvs::AbstractInterval, posangle; yfunc=abs, uvscale=identity, model=nothing, kwargs...) =
	FPlot((),
		Ref(uvs),
		Ref(@o visibility(yfunc, model, _ * SVector(sincos(posangle))) |> ustrip);
		axis=(;
			xlabel="UV projection (λ)",
			ylabel=_ylabel_by_func(yfunc),
			limits=(
				extrema(uvs),
				_ylims_by_func(yfunc),
			),
			to_x_attrs((scale=uvscale, tickformat=EngTicks(:symbol)))...,
			get(kwargs, :axis, (;))...,
		),
		delete(NamedTuple(kwargs), (@maybe _.axis))...,
	)

_ylabel_by_func(::typeof(abs)) = "Amplitude"
_ylabel_by_func(::typeof(angle)) = "Phase (rad)"
_ylabel_by_func(::typeof(rad2deg∘angle)) = "Phase (°)"

_ylims_by_func(_) = nothing
_ylims_by_func(::typeof(abs)) = (0, nothing)
# _ylims_by_func(::typeof(angle)) = (-π, π)
# _ylims_by_func(::typeof(rad2deg∘angle)) = (-180, 180)
