using VLBIPlots
using InterferometricModels
using IntervalSets
using StaticArrays
using Test


comp = beam(EllipticGaussian, σ_major=0.5, ratio_minor_major=0.5, pa_major=deg2rad(15))

VLBIPlots.plt.gca().add_artist(BeamArtist(comp))

radplot(abs, comp, 0..1e9)
radplot(angle, comp, 0..1e9)

radplot([abs, angle], [(uv=SVector(0, 0), visibility=1-2im), (uv=SVector(1e3, 0), visibility=1+2im)], ax=[VLBIPlots.plt.gca(), VLBIPlots.plt.gca()])
radplot([abs, angle], comp, [(uv=SVector(0, 0),), (uv=SVector(1e3, 0),)], ax=[VLBIPlots.plt.gca(), VLBIPlots.plt.gca()])

plot_imageplane(comp)
plot_imageplane(MultiComponentModel((comp,)))


import CompatHelperLocal as CHL
CHL.@check()
