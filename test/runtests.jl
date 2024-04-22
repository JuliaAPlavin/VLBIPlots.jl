using VLBIPlots
using Makie
using InterferometricModels
using IntervalSets
using StaticArrays
using Test


@testset "rad, proj plots" begin
    uvtbl = [(uv=SVector(0, 0), visibility=1-2im), (uv=SVector(1e3, 0), visibility=1+2im)]
    comp = beam(EllipticGaussian, σ_major=0.5, ratio_minor_major=0.5, pa_major=deg2rad(15))

    scatter(RadPlot(uvtbl))
    scatter(RadPlot(uvtbl; yfunc=rad2deg∘angle))
    scatter(ProjPlot(uvtbl, 0))
    scatter(ProjPlot(uvtbl, 0; yfunc=rad2deg∘angle))

    scatter(RadPlot(uvtbl; model=comp))
    scatter(RadPlot(uvtbl; model=comp, yfunc=rad2deg∘angle))
    scatter(ProjPlot(uvtbl, 0; model=comp))
    scatter(ProjPlot(uvtbl, 0; model=comp, yfunc=rad2deg∘angle))

    band(RadPlot(0..10; model=comp))
    band(RadPlot(0..10; model=comp, yfunc=rad2deg∘angle)) 
end


# VLBIPlots.plt.gca().add_artist(BeamArtist(comp))

# plot_imageplane(comp)
# plot_imageplane(MultiComponentModel((comp,)))


import CompatHelperLocal as CHL
CHL.@check()
