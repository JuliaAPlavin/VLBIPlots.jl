using TestItems
using TestItemRunner
@run_package_tests


@testitem "rad, proj, uv plots" begin
    using InterferometricModels
    using StaticArrays
    using IntervalSets
    using Makie
    using Unitful

    uvtbl = [(uv=SVector(0., 0), visibility=1-2im), (uv=SVector(1e3, 1e2), visibility=1+2im)]
    comps = Any[
        beam(EllipticGaussian, σ_major=0.5, ratio_minor_major=0.5, pa_major=deg2rad(15)).comp,
        CircularGaussian(flux=1.0u"W", σ=1.0u"°", coords=SVector(0., 0)u"°"),
    ]

    scatter(RadPlot(uvtbl), doaxis=true)
    @test current_axis().xlabel[] == "UV distance (λ)"
    scatter(RadPlot(uvtbl; yfunc=rad2deg∘angle), doaxis=true)
    @test current_axis().xlabel[] == "UV distance (λ)"
    scatter(ProjPlot(uvtbl, 0), doaxis=true)
    @test current_axis().xlabel[] == "UV projection (λ)"
    scatter(ProjPlot(uvtbl, 0; yfunc=rad2deg∘angle), doaxis=true)
    @test current_axis().xlabel[] == "UV projection (λ)"

    scatter(UVPlot(uvtbl), doaxis=true)
    @test current_axis().xlabel[] == "U (λ)"
    scatter!(UVPlot(uvtbl))

    scatter(UVPlot(uvtbl, uvscale=VLBIPlots.SymLog(2)), doaxis=true)
    scatter!(UVPlot(uvtbl))  # XXX: wrong results
    scatter!(UVPlot(uvtbl, uvscale=log10))

    @testset for comp in comps
        scatter(RadPlot(uvtbl; model=comp), doaxis=true)
        @test current_axis().xlabel[] == "UV distance (λ)"
        scatter(RadPlot(uvtbl; model=comp, yfunc=rad2deg∘angle), doaxis=true)
        scatter(ProjPlot(uvtbl, 0; model=comp), doaxis=true)
        @test current_axis().xlabel[] == "UV projection (λ)"
        scatter(ProjPlot(uvtbl, 0; model=comp, yfunc=rad2deg∘angle), doaxis=true)

        band(RadPlot(0..10; model=comp), doaxis=true)
        @test current_axis().xlabel[] == "UV distance (λ)"
        band(RadPlot(0..10; model=comp, yfunc=rad2deg∘angle), doaxis=true)
        scatter(ProjPlot(0..10, 0; model=comp), doaxis=true)
        @test current_axis().xlabel[] == "UV projection (λ)"
        scatter(ProjPlot(0..10, 0; model=comp, yfunc=rad2deg∘angle), doaxis=true)
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
