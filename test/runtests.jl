using TestItems
using TestItemRunner
@run_package_tests


@testitem "rad, proj, uv plots" begin
    using InterferometricModels
    using StaticArrays
    using IntervalSets
    using MakieExtra
    using Unitful

    uvtbl = [(spec=SVector(0., 0), visibility=1-2im), (spec=SVector(1e3, 1e2), visibility=1+2im)]
    comps = Any[
        beam(EllipticGaussian, σ_major=0.5, ratio_minor_major=0.5, pa_major=deg2rad(15)).comp,
        CircularGaussian(flux=1.0u"W", σ=1.0u"°", coords=SVector(0., 0)u"°"),
    ]

    axplot(scatter)(RadPlot(uvtbl))
    @test current_axis().xlabel[] == "UV distance (λ)"
    axplot(scatter)(RadPlot(uvtbl; yfunc=rad2deg∘angle))
    @test current_axis().xlabel[] == "UV distance (λ)"
    axplot(scatter)(ProjPlot(uvtbl, 0))
    @test current_axis().xlabel[] == "UV projection (λ)"
    axplot(scatter)(ProjPlot(uvtbl, 0; yfunc=rad2deg∘angle))
    @test current_axis().xlabel[] == "UV projection (λ)"

    axplot(scatter)(UVPlot(uvtbl))
    @test current_axis().xlabel[] == "U (λ)"
    scatter!(UVPlot(uvtbl))

    axplot(scatter)(UVPlot(uvtbl, uvscale=VLBIPlots.SymLog(2)))
    scatter!(UVPlot(uvtbl))  # XXX: wrong results
    scatter!(UVPlot(uvtbl, uvscale=log10))

    @testset for comp in comps
        axplot(scatter)(RadPlot(uvtbl; model=comp))
        @test current_axis().xlabel[] == "UV distance (λ)"
        axplot(scatter)(RadPlot(uvtbl; model=comp, yfunc=rad2deg∘angle))
        axplot(scatter)(ProjPlot(uvtbl, 0; model=comp))
        @test current_axis().xlabel[] == "UV projection (λ)"
        axplot(scatter)(ProjPlot(uvtbl, 0; model=comp, yfunc=rad2deg∘angle))

        axplot(band)(RadPlot(0..10; model=comp))
        @test current_axis().xlabel[] == "UV distance (λ)"
        axplot(band)(RadPlot(0..10; model=comp, yfunc=rad2deg∘angle))
        axplot(scatter)(ProjPlot(0..10, 0; model=comp))
        @test current_axis().xlabel[] == "UV projection (λ)"
        axplot(scatter)(ProjPlot(0..10, 0; model=comp, yfunc=rad2deg∘angle))
    end
end

@testitem "model poly, image, beam" begin
    using InterferometricModels
    using StaticArrays
    using Unitful
    using VLBIPlots.MakieExtra

    models = Any[
        MultiComponentModel([
            CircularGaussian(flux=7, σ=1.5u"°", coords=SVector(0.1, 0.5)u"°"),
            EllipticGaussian(flux=7, σ_major=1u"°", ratio_minor_major=0.3, pa_major=0.5, coords=SVector(1, 3.5)u"°"),
            # EllipticGaussian(flux=7, σ_major=1.5u"°", ratio_minor_major=0.3, pa_major=-0.5, coords=SVector(1, 3.5)u"°") |> EllipticGaussianCovmat,
        ]),
        MultiComponentModel([
            CircularGaussian(flux=7, σ=1.5u"°", coords=SVector(0.1, 0.5)u"°"),
        ]),
        MultiComponentModel((
            CircularGaussian(flux=7, σ=1.5u"°", coords=SVector(0.1, 0.5)u"°"),
            EllipticGaussian(flux=7, σ_major=1u"°", ratio_minor_major=0.3, pa_major=0.5, coords=SVector(1, 3.5)u"°"),
            # EllipticGaussian(flux=7, σ_major=1.5u"°", ratio_minor_major=0.3, pa_major=-0.5, coords=SVector(1, 3.5)u"°") |> EllipticGaussianCovmat,
        )),
        MultiComponentModel((
            CircularGaussian(flux=7, σ=1.5u"°", coords=SVector(0.1, 0.5)u"°"),
        )),
        MultiComponentModel([
            CircularGaussian(flux=7u"W", σ=1.5u"°", coords=SVector(0.1, 0.5)u"°"),
            EllipticGaussian(flux=7u"W", σ_major=1u"°", ratio_minor_major=0.3, pa_major=0.5, coords=SVector(1, 3.5)u"°"),
            # EllipticGaussian(flux=7u"W", σ_major=1.5u"°", ratio_minor_major=0.3, pa_major=-0.5, coords=SVector(1, 3.5)u"°") |> EllipticGaussianCovmat,
        ]),
    ]
    @testset for model in models
        fig, ax, _ = image(model, colorscale=SymLog(1e-1), colormap=:turbo, npix=20)
        image!(-1..1, -1..1, model)
        image!(-1:0.1:1, -1:0.1:1, model)
        @test_throws Exception image!(model, npix="abc")  # to ensure that kwargs aren't just ignored
        poly(model, strokewidth=2, color=(:black, 0), strokecolor=:white)
        scatter(model)
        beampoly!(ax, beam(CircularGaussian, σ=0.3), color=(:red, 0.2))
        beampoly!(Observable(beam(CircularGaussian, σ=0.3)), position=(0.1, 0.1), color=(:red, 0.2))
    end
    models = [
        MultiComponentModel([
            InterferometricModels.Point(flux=7u"W", coords=SVector(0.1, 0.5)u"°"),
            CircularGaussian(flux=7u"W", σ=1.5u"°", coords=SVector(0.1, 0.5)u"°"),
            EllipticGaussian(flux=7u"W", σ_major=1u"°", ratio_minor_major=0.3, pa_major=0.5, coords=SVector(1, 3.5)u"°"),
            # EllipticGaussian(flux=7u"W", σ_major=1.5u"°", ratio_minor_major=0.3, pa_major=-0.5, coords=SVector(1, 3.5)u"°") |> EllipticGaussianCovmat,
        ]),
    ]
    @testset for model in models
        poly(model, strokewidth=2, color=(:black, 0), strokecolor=:white)
        scatter(model)
    end
end

@testitem "_" begin
    import Aqua
    Aqua.test_all(VLBIPlots; ambiguities=false, undefined_exports=false, piracies=false, persistent_tasks=false)

    import CompatHelperLocal as CHL
    CHL.@check()
end
