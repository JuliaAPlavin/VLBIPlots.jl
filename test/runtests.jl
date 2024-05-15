using TestItems
using TestItemRunner
@run_package_tests


@testitem "rad, proj, uv plots" begin
    using InterferometricModels
    using StaticArrays
    using IntervalSets
    using Makie

    uvtbl = [(uv=SVector(0., 0), visibility=1-2im), (uv=SVector(1e3, 0), visibility=1+2im)]
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
    scatter(ProjPlot(0..10, 0; model=comp))
    scatter(ProjPlot(0..10, 0; model=comp, yfunc=rad2deg∘angle))

    scatter(UVPlot(uvtbl))
    scatter!(UVPlot(uvtbl))

    scatter(UVPlot(uvtbl, uvscale=log10))
    scatter!(UVPlot(uvtbl))  # XXX: wrong results
    scatter!(UVPlot(uvtbl, uvscale=log10))
end

@testitem "model poly, image, beam" begin
    using InterferometricModels
    using StaticArrays
    using Unitful
    using VLBIPlots.MakieExtra

    model = MultiComponentModel([
        CircularGaussian(flux=7, σ=1.5u"°", coords=SVector(0.1, 0.5)u"°"),
        EllipticGaussian(flux=7, σ_major=1u"°", ratio_minor_major=0.3, pa_major=0.5, coords=SVector(1, 3.5)u"°"),
        # EllipticGaussian(flux=7, σ_major=1.5u"°", ratio_minor_major=0.3, pa_major=-0.5, coords=SVector(1, 3.5)u"°") |> EllipticGaussianCovmat,
    ])
    model_unif = MultiComponentModel([
        CircularGaussian(flux=7, σ=1.5u"°", coords=SVector(0.1, 0.5)u"°"),
    ])
    fig, ax, _ = image(model, colorscale=SymLog(1e-1), colormap=:turbo, npix=20)
    poly(model, strokewidth=2, color=(:black, 0), strokecolor=:white)
    poly(model_unif, strokewidth=2, color=(:black, 0), strokecolor=:white)
    scatter(model)
    beampoly!(ax, beam(CircularGaussian, σ=0.3), centerax=(0.1, 0.1), color=(:red, 0.2))


    model = MultiComponentModel([
        CircularGaussian(flux=7u"W", σ=1.5u"°", coords=SVector(0.1, 0.5)u"°"),
        EllipticGaussian(flux=7u"W", σ_major=1u"°", ratio_minor_major=0.3, pa_major=0.5, coords=SVector(1, 3.5)u"°"),
        # EllipticGaussian(flux=7u"W", σ_major=1.5u"°", ratio_minor_major=0.3, pa_major=-0.5, coords=SVector(1, 3.5)u"°") |> EllipticGaussianCovmat,
    ])
    fig, ax, _ = poly(model)
    image!(ax, model, xyintervals=(-5u"°"..5u"°"))
    scatter!(ax, model)
    beampoly!(ax, beam(CircularGaussian, σ=0.3), centerax=(0.1, 0.1), color=(:red, 0.2))
end

@testitem "_" begin
    import Aqua
    Aqua.test_all(VLBIPlots; ambiguities=false, undefined_exports=false, piracies=false, persistent_tasks=false)

    import CompatHelperLocal as CHL
    CHL.@check()
end
