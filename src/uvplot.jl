function uvplot(c::AbstractVector{<:NamedTuple}; color=@optic(_.visibility |> abs), kwargs...)
	plt.scatter(
		(@p c map(first(_.uv))),
		(@p c map(last(_.uv))),
		c=(@p c map(color(_))),
		s=1,
		norm=matplotlib.colors.LogNorm(),
        kwargs...
	)
	plt.gca().set_aspect(:equal)
	plt.colorbar().ax.set_title(color == @optic(_.visibility |> abs) ? "Amplitude (Jy)" : Accessors._shortstring("", color))
    xylabels("U (λ)", "V (λ)")
end
