UVPlot(tbl; uvscale=identity) = FPlot(tbl,
	x -> (_uvfunc(uvscale)(_uv(x))),
	axis=(;
	    xlabel="U (λ)", ylabel="V (λ)",
		aspect=DataAspect(), autolimitaspect=1,
		to_xy_attrs((scale=uvscale, tickformat=EngTicks(:symbol)))...
	)
)

_uvfunc(uvscale) = function(uv)
    uv′ = @modify(uvscale, norm(uv))
    return inverse(uvscale).(uv′)
end
