using VLBIPlots
using InterferometricModels
using Test


BeamArtist(beam(EllipticGaussian, σ_major=0.5, ratio_minor_major=0.5, pa_major=deg2rad(15)))


import CompatHelperLocal as CHL
CHL.@check()
