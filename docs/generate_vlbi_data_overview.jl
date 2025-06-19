#!/usr/bin/env julia

using Pkg
Pkg.activate(@__DIR__)

using VLBIPlots
using VLBIFiles
import GLMakie
using MakieExtra
using Unitful
using VLBIFiles.Uncertain

# Load real VLBI data directly from VLBIFiles test data
test_data_path = joinpath(dirname(pathof(VLBIFiles)), "../test/data/SR1_3C279_2017_101_hi_hops_netcal_StokesI.uvfits")
uvdata = VLBIFiles.load(test_data_path)

# Extract UV table for plotting
uvtbl = uvtable(uvdata) |> VLBI.add_conjvis

# Create a comprehensive figure with all three plot types
fig = Figure(size=(900, 400))
angle = 30u"°"

kws = (;markersize=2, color=r -> U.value(abs(r.value)), colormap=:turbo)

# RadPlot: Visibility amplitude vs UV distance
ax1, plt1 = axplot(scatter)(fig[1, 1], RadPlot(uvtbl; kws...))

# ProjPlot: Projection at 0° (horizontal baseline projection)
ax2, plt2 = axplot(scatter)(fig[1, 2], ProjPlot(uvtbl, angle; kws...))

# UVPlot: UV coverage scatter plot
ax3, plt3 = axplot(scatter)(fig[1, 3], UVPlot(uvtbl; kws...))
lines!((@lift [(0,0), 100e9 .* sincos(angle)]); color=:black, to_xy_attrs(autolimits=false)...)

# Save the VLBI data overview plot
output_file = "images/vlbi_data_overview.png"
mkpath(dirname(output_file))
save(output_file, fig; px_per_unit=1)
println("VLBI data overview plot saved to $output_file")
