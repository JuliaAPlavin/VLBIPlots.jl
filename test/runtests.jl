using VLBIPlots
using InterferometricModels
using IntervalSets
using Test


comp = beam(EllipticGaussian, σ_major=0.5, ratio_minor_major=0.5, pa_major=deg2rad(15))

BeamArtist(comp)

radplot(abs, comp, 0..1e9)
radplot(angle, comp, 0..1e9)

plot_imageplane(comp)
plot_imageplane(MultiComponentModel((comp,)))


import CompatHelperLocal as CHL
CHL.@check()
