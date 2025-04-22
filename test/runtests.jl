using TestItems
using TestItemRunner
@run_package_tests


@testitem "rad, proj, uv plots" begin
    using InterferometricModels
    using StaticArrays
    using IntervalSets
    using MakieExtra
    using Unitful
    import VLBISkyModels as VSM


    uvtbl = [(spec=SVector(0., 0), value=1-2im), (spec=SVector(1e3, 1e2), value=1+2im)]
    models = Any[
        beam(EllipticGaussian, σ_major=0.5, ratio_minor_major=0.5, pa_major=deg2rad(15)).comp,
        CircularGaussian(flux=1.0u"W", σ=1.0u"°", coords=SVector(0., 0)u"°"),
        MultiComponentModel((
            CircularGaussian(flux=7, σ=1.5u"°", coords=SVector(0.1, 0.5)u"°"),
            EllipticGaussian(flux=7, σ_major=1u"°", ratio_minor_major=0.3, pa_major=0.5, coords=SVector(1, 3.5)u"°"),
        )),
        VSM.modify(VSM.MRing(0.1, -0.2), VSM.Stretch(VSM.μas2rad(30)))
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

    @testset for model in models
        axplot(scatter)(RadPlot(uvtbl; model))
        @test current_axis().xlabel[] == "UV distance (λ)"
        axplot(scatter)(RadPlot(uvtbl; model, yfunc=rad2deg∘angle))
        axplot(scatter)(ProjPlot(uvtbl, 0; model))
        @test current_axis().xlabel[] == "UV projection (λ)"
        axplot(scatter)(ProjPlot(uvtbl, 0; model, yfunc=rad2deg∘angle))

        axplot(band)(RadPlot(0..10; model))
        @test current_axis().xlabel[] == "UV distance (λ)"
        axplot(band)(RadPlot(0..10; model, yfunc=rad2deg∘angle))
        axplot(scatter)(ProjPlot(0..10, 0; model))
        @test current_axis().xlabel[] == "UV projection (λ)"
        axplot(scatter)(ProjPlot(0..10, 0; model, yfunc=rad2deg∘angle))

        image(UVPlot(0±10; model))
    end
end

@testitem "uvplot for specs" begin
    using Makie
    using VLBIData

    @testset for spec in [
        # VisSpec(VLBI.Baseline(1, (1, 2)), UV(10., 0)),
        ClosurePhaseSpec((
            VisSpec(VLBI.Baseline(1, (1, 2)), UV(10., 0)),
            VisSpec(VLBI.Baseline(1, (2, 3)), UV(0., 10)),
            VisSpec(VLBI.Baseline(1, (3, 1)), UV(10., 10)),
        )),
        ClosureAmpSpec((
            VisSpec(VLBI.Baseline(1, (1, 2)), UV(10., 0)),
            VisSpec(VLBI.Baseline(1, (2, 3)), UV(0., 10)),
            VisSpec(VLBI.Baseline(1, (3, 4)), UV(10., 10)),
            VisSpec(VLBI.Baseline(1, (4, 1)), UV(10., 20)),
        )),
    ]
        lines(UVPlot(spec))
    end
end

@testitem "axfuncs" begin
    using StaticArrays
    using MakieExtra
    using VLBIData
    using Dates

    uvtbl = [(spec=VLBI.VisSpec(VLBI.Baseline(1, (1, 2)), UV(0., 0)), value=1-2im, datetime=now()),
             (spec=VLBI.VisSpec(VLBI.Baseline(1, (1, 2)), UV(1e3, 1e2)), value=1+2im, datetime=now())]
    axplot(scatter)(FPlot(uvtbl, VLBIPlots.AxFuncs.UVdist(), VLBIPlots.AxFuncs.vis_amp()))
    axplot(scatter)(FPlot(uvtbl, VLBIPlots.AxFuncs.vis_phase(), VLBIPlots.AxFuncs.baseline()))
    axplot(scatter)(FPlot(uvtbl, VLBIPlots.AxFuncs.Time(), VLBIPlots.AxFuncs.baseline()))
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
