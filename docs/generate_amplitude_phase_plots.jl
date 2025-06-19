#!/usr/bin/env julia

using Pkg
Pkg.activate(@__DIR__)

using VLBIPlots
using VLBIFiles
using GLMakie
using MakieExtra

# Load UV data directly from VLBIFiles test data
test_data_path = joinpath(dirname(pathof(VLBIFiles)), "../test/data/SR1_3C279_2017_101_hi_hops_netcal_StokesI.uvfits")
uvdata = VLBIFiles.load(test_data_path)

# Extract UV table for plotting
uvtbl = uvtable(uvdata)

# Create a radial plot using VLBIPlots.RadPlot
fig = Figure(size=(800, 600))

fplt = RadPlot(uvtbl; markersize=2)

# Create RadPlot for visibility amplitudes
(ax1,), = multiplot((axplot(scatter), rangebars), fig[1, 1], fplt)

# Create RadPlot for visibility phases  
(ax2,), = multiplot((axplot(scatter), rangebars), fig[2, 1], RadPlot(fplt; yfunc=rad2deg∘angle); axis=(limits=(nothing, (-180, 180)), height=200))

linkxaxes!(ax1, ax2)

# Save the plot
output_file = "images/amplitude_phase_plots.png"
mkpath(dirname(output_file))
save(output_file, fig; px_per_unit=1)
println("Amplitude and phase plots saved to $output_file")
