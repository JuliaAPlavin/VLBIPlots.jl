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

# XXX: piracy, https://github.com/JuliaObjects/Accessors.jl/pull/162
function Accessors.set(arr, ::typeof(norm), val::Number)
	omul = iszero(val) ? one(norm(arr)) : norm(arr)
	map(Base.Fix2(*, val / omul), arr)
end
