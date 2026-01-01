U(;uvscale=identity, kwargs...) = AxFunc(
    x -> first(_uvfunc(uvscale)(UV(x)));
    label="U (λ)", scale=uvscale, tickformat=EngTicks(:symbol),
    kwargs...)
V(;uvscale=identity, kwargs...) = AxFunc(
    x -> last(_uvfunc(uvscale)(UV(x)));
    label="V (λ)", scale=uvscale, tickformat=EngTicks(:symbol),
    kwargs...)

UVdist(;uvscale=identity, kwargs...) = AxFunc(
    norm ∘ UV;
    label="UV distance (λ)", scale=uvscale, tickformat=EngTicks(:symbol),
    kwargs...)

UVdist_u(u; uvscale=identity, kwargs...) = AxFunc(
    r -> norm(VLBI.UV(r)) * (u"c"/VLBI.frequency(r)) |> u |> ustrip;
    label="Baseline ($u)", scale=uvscale, tickformat=EngTicks(:symbol),
    kwargs...)

UVproj(posangle; uvscale=identity, kwargs...) = AxFunc(
    (@o dot(UV(_), sincos(posangle)));
    label="UV projection (λ)", scale=uvscale, tickformat=EngTicks(:symbol),
    kwargs...)

UVarea_sqrt(; kwargs...) = AxFunc(
	sqrt ∘ UVarea,
    label="√area (λ)", tickformat=EngTicks(:symbol), kwargs...)

_uvfunc(uvscale) = function(uv)
    uv′ = @modify(uvscale, norm(uv))
    return inverse(uvscale).(uv′)
end
    

visf(f; model=nothing, limit=_visfunclims(f), kwargs...) = AxFunc(
    isnothing(model) ?
        f ∘ visibility :
        (@o visibility(f, model, UV(_)) |> ustrip);
    limit, kwargs...)

visf(::typeof(abs); kwargs...) = @invoke visf(abs::Function; label="Amplitude", kwargs...)
visf(::typeof(angle); kwargs...) = @invoke visf(angle::Function; label="Phase", ticks=Makie.AngularTicks(rad2deg(1), "°"), kwargs...)
visf(::typeof(rad2deg ∘ angle); kwargs...) = @invoke visf((rad2deg ∘ angle)::Function; label="Phase (°)", kwargs...)

vis_amp(; kwargs...) = visf(abs; kwargs...)
vis_phase(; kwargs...) = visf(angle; kwargs...)

_visfunclims(_) = nothing
_visfunclims(::typeof(abs)) = (0, nothing)


DateTime(; kwargs...) = AxFunc(label="Datetime", (@o _.datetime), kwargs...)
Time(; kwargs...) = AxFunc(label="Time of day", (@o _.datetime |> Dates.Time), kwargs...)
baseline(; kwargs...) = AxFunc(label="Baseline", x -> join(VLBI.antenna_names(x), " – "), kwargs...)
