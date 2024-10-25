UVPlot(fplt::FPlot; uvscale=identity, kwargs...) = @p let
	fplt
	@insert __[1] = x -> (_uvfunc(uvscale)(_uv(x)))
	@set __.axis = (;
		xlabel="U (λ)", ylabel="V (λ)",
		aspect=DataAspect(), autolimitaspect=1,
		to_xy_attrs((scale=uvscale, tickformat=EngTicks(:symbol)))...,
		fplt.axis...,
		get(kwargs, :axis, (;))...,
	)
	setproperties(__, delete(NamedTuple(kwargs), (@maybe _.axis)))
end

UVPlot(tbl; uvscale=identity, kwargs...) = UVPlot(FPlot(tbl); uvscale, kwargs...)

_uvfunc(uvscale) = function(uv)
    uv′ = @modify(uvscale, norm(uv))
    return inverse(uvscale).(uv′)
end
