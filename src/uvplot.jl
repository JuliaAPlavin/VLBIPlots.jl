UVPlot(fplt::FPlot; uvscale=identity, kwargs...) = @p let
	fplt
	@insert __[1] = AxFuncs.U(;uvscale)
	@insert __[2] = AxFuncs.V(;uvscale)
	@set __.axis = (;
		aspect=DataAspect(), autolimitaspect=1,
		fplt.axis...,
		get(kwargs, :axis, (;))...,
	)
	setproperties(__, delete(NamedTuple(kwargs), (@maybe _.axis)))
end

UVPlot(tbl; uvscale=identity, kwargs...) = UVPlot(FPlot(tbl); uvscale, kwargs...)
