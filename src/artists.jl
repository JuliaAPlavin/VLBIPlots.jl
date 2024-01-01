function BeamArtist(beam; ax=plt.gca(), facecolor=:lightgreen, edgecolor=:k, linewidth=0.5, loc="lower left", pad=0.1)
	box = matplotlib.offsetbox.AuxTransformBox(ax.transData)
	box.add_artist(
		matplotlib.patches.Ellipse(
			(0, 0),
			ustrip(fwhm_min(beam)), ustrip(fwhm_max(beam));
			angle=-rad2deg(position_angle(beam)),
			facecolor, edgecolor, linewidth
		)
	)
	return matplotlib.offsetbox.AnchoredOffsetbox(; loc, pad, child=box, frameon=false)
end
