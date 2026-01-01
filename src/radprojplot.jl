RadPlot(fplt::FPlot; yfunc=abs, uvscale=identity, model=nothing, axis=(;), kwargs...) = @p let
	fplt
	set(__, (@maybe _[1]), AxFuncs.UVdist(;uvscale, limit=(@p fplt.data maximum(norm(UV(_))) (-0.02*__, 1.05*__))))
	set(__, (@maybe _[2]), AxFuncs.visf(yfunc; model))
	@set __.axis = merge(fplt.axis, axis)
	setproperties(__, delete(NamedTuple(kwargs), (@maybe _.axis)))
end

RadPlot(tbl::AbstractVector; kwargs...) = RadPlot(FPlot(tbl); kwargs...)

function RadPlot(uvs::Union{AbstractInterval,AbstractVector{<:Number}}; yfunc=abs, uvscale=identity, model=nothing, kwargs...)
	visf_noenvelope = AxFuncs.visf(yfunc; model)
	FPlot((),
		Ref(uvs),
		Ref(@o visibility_envelope(yfunc, model, _) |> _ustrip_i);
		axis=(;
			xlabel="UV distance (λ)",
			ylabel=MakieExtra.shortlabel(visf_noenvelope),
			limits=(
				extrema(uvs),
				AxFuncs._visfunclims(yfunc),
			),
			to_x_attrs((scale=uvscale, tickformat=EngTicks(:symbol)))...,
			get(kwargs, :axis, (;))...,
		),
		delete(NamedTuple(kwargs), (@maybe _.axis))...,
	)
end


ProjPlot(fplt::FPlot, posangle; yfunc=abs, uvscale=identity, model=nothing, axis=(;), kwargs...) = @p let
	fplt
	set(__, (@maybe _[1]), AxFuncs.UVproj(posangle; uvscale, limit=(@p fplt.data maximum(norm(UV(_))) (-0.02*__, 1.05*__))))
	set(__, (@maybe _[2]), AxFuncs.visf(yfunc; model))
	@set __.axis = merge(fplt.axis, axis)
	setproperties(__, delete(NamedTuple(kwargs), (@maybe _.axis)))
end

ProjPlot(tbl::AbstractVector, posangle; kwargs...) = ProjPlot(FPlot(tbl), posangle; kwargs...)

function ProjPlot(uvs::Union{AbstractInterval,AbstractVector{<:Number}}, posangle; yfunc=abs, uvscale=identity, model=nothing, kwargs...)
	visf_noenvelope = AxFuncs.visf(yfunc; model)
	FPlot((),
		Ref(uvs),
		Ref(@o visibility(yfunc, model, _ * SVector(sincos(posangle))) |> ustrip);
		axis=(;
			xlabel="UV projection (λ)",
			ylabel=MakieExtra.shortlabel(visf_noenvelope),
			limits=(
				extrema(uvs),
				AxFuncs._visfunclims(yfunc),
			),
			to_x_attrs((scale=uvscale, tickformat=EngTicks(:symbol)))...,
			get(kwargs, :axis, (;))...,
		),
		delete(NamedTuple(kwargs), (@maybe _.axis))...,
	)
end
