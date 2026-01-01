UVPlot(fplt::FPlot; uvscale=identity, kwargs...) = @p let
	fplt
	@insert __[1] = AxFuncs.U(;uvscale)
	@insert __[2] = AxFuncs.V(;uvscale)
	@set __.axis = (;
		aspect=DataAspect(), autolimitaspect=1,
		xreversed=true,
		fplt.axis...,
		get(kwargs, :axis, (;))...,
	)
	setproperties(__, delete(NamedTuple(kwargs), (@maybe _.axis)))
end

UVPlot(tbl; uvscale=identity, kwargs...) = UVPlot(FPlot(tbl); uvscale, kwargs...)


UVPlot(uvs::AbstractInterval; kwargs...) = UVPlot(uvs, uvs; kwargs...)
UVPlot(us::AbstractInterval, vs::AbstractInterval; npix::Int=200, kwargs...) = UVPlot(range(us, length=npix), range(us, length=npix); kwargs...)
UVPlot(us::AbstractRange, vs::AbstractRange; model, color=x -> abs(x.value)) = map(uv -> color((value=visibility(model)(uv), uv=uv)), grid(SVector, U=us, V=vs))
