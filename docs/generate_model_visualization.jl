#!/usr/bin/env julia

"""
Generate model components example image for VLBIPlots.jl documentation.
"""

using Pkg
Pkg.activate(@__DIR__)

using VLBIPlots
using InterferometricModels
using StaticArrays
using Unitful
using UnitfulAngles
using GLMakie
using MakieExtra

# Set up GLMakie for headless rendering
GLMakie.activate!()

# Create output directory for images
mkpath(joinpath(@__DIR__, "images"))

# Here we create a model manually - use VLBIFiles.jl to read a model from file
model = MultiComponentModel([
    EllipticGaussian(flux=1.0, σ_major=0.4u"mas", ratio_minor_major=0.6, 
                     pa_major=π/3, coords=SVector(0.0, 0.0)u"mas"),
    CircularGaussian(flux=0.6, σ=0.8u"mas", coords=SVector(1.2, 0.7)u"mas"),
    CircularGaussian(flux=0.3, σ=1.5u"mas", coords=SVector(2.4, 1.4)u"mas")
])

println("Generating model components example...")

# Create combined plot with all three visualization types
fig = Figure()
ax = Axis(fig[1,1], limits=(-3..6, -2.5..5))

# Start with intensity image as background
image!(ax, model, colormap=:inferno, colorscale=SymLog(0.03))

# Overlay polygon shapes showing component extents
poly!(ax, model, color=(:white, 0), strokewidth=2, strokecolor=:white)

# Add scatter points showing component centers
scatter!(ax, model, markersize=8, color=:yellow, strokewidth=1, strokecolor=:black)

resize_to_layout!()
# Save the model visualization
save(joinpath(@__DIR__, "images", "model_visualization.png"), fig; px_per_unit=1)

println("Model components example generated successfully!")
println("Image saved to: $(joinpath(@__DIR__, "images", "model_components_example.png"))")
