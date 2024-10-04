RadPlot(tbl::AbstractVector; yfunc=abs, uvscale=identity, model=nothing, kwargs...) =
	FPlot(tbl,
		norm ∘ _uv,
		isnothing(model) ?
			yfunc ∘ _visibility :
			(@o visibility(yfunc, model, _uv(_)) |> ustrip);
		axis=(;
			xlabel="UV distance (λ)",
			ylabel=_ylabel_by_func(yfunc),
			limits=(
				(@p tbl maximum(norm(_uv(_))) 1.05*__ (0, __)),
				_ylims_by_func(yfunc),
			),
			to_x_attrs((scale=uvscale, tickformat=EngTicks(:symbol)))...,
			get(kwargs, :axis, (;))...,
		),
		delete(NamedTuple(kwargs), (@maybe _.axis))...,
	)

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

ProjPlot(tbl::AbstractVector, posangle; yfunc=abs, uvscale=identity, model=nothing, kwargs...) =
	FPlot(tbl,
		(@o dot(_uv(_), sincos(posangle))),
		isnothing(model) ?
			yfunc ∘ _visibility :
			(@o visibility(yfunc, model, _uv(_)) |> ustrip);
		axis=(;
			xlabel="UV projection (λ)",
			ylabel=_ylabel_by_func(yfunc),
			limits=(
				(@p tbl maximum(norm(_uv(_))) 1.05*__ (0, __)),
				_ylims_by_func(yfunc),
			),
			to_x_attrs((scale=uvscale, tickformat=EngTicks(:symbol)))...,
			get(kwargs, :axis, (;))...,
		),
		delete(NamedTuple(kwargs), (@maybe _.axis))...,
	)

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
