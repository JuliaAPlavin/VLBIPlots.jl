#!/usr/bin/env julia

using Pkg
Pkg.activate(@__DIR__)

using VLBIPlots
using VLBIFiles
import GLMakie
using MakieExtra
using InterferometricModels
using StaticArrays
using Unitful
using UnitfulAngles

# Load real VLBI data directly from VLBIFiles test data
test_data_path = joinpath(dirname(pathof(VLBIFiles)), "../test/data/SR1_3C279_2017_101_hi_hops_netcal_StokesI.uvfits")
uvdata = VLBIFiles.load(test_data_path)

# Extract UV table for plotting
uvtbl = uvtable(uvdata)

# Create a simple model (e.g., elliptical Gaussian component)
model = EllipticGaussian(flux=4.0, σ_major=0.02u"mas", 
                        ratio_minor_major=0.6, pa_major=π/4, 
                        coords=SVector(0.0, 0.0)u"mas")

# Plot data and overplot model predictions
fplt = RadPlot(uvtbl; markersize=2)

# Amplitude plot with model overlay
figaxplt, plt = multiplot((axplot(scatter), rangebars), fplt)
fig, ax, _ = figaxplt
scatter!(ax, RadPlot(uvtbl; model), markersize=3, color=:red)
band!(ax, RadPlot(0..8e9; model), color=(:red, 0.2))

# Save the plot
output_file = "images/model_data_comparison.png"
mkpath(dirname(output_file))
save(output_file, fig; px_per_unit=1)
println("Model vs data comparison plot saved to $output_file")
