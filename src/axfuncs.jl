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

UVproj(posangle; uvscale=identity, kwargs...) = AxFunc(
    (@o dot(UV(_), sincos(posangle)));
    label="UV projection (λ)", scale=uvscale, tickformat=EngTicks(:symbol),
    kwargs...)

_uvfunc(uvscale) = function(uv)
    uv′ = @modify(uvscale, norm(uv))
    return inverse(uvscale).(uv′)
end
    

visf(f; label=_visfunclabel(f), limit=_visfunclims(f), model=nothing, kwargs...) = AxFunc(
    isnothing(model) ?
        f ∘ visibility :
        (@o visibility(f, model, UV(_)) |> ustrip);
    label, limit, kwargs...)

vis_amp(; model=nothing, kwargs...) = visf(abs; model, kwargs...)
vis_phase(postf=rad2deg; model=nothing, kwargs...) = visf(postf ∘ angle; model, kwargs...)

_visfunclabel(::typeof(abs)) = "Amplitude"
_visfunclabel(::typeof(angle)) = "Phase (rad)"
_visfunclabel(::typeof(rad2deg∘angle)) = "Phase (°)"

_visfunclims(_) = nothing
_visfunclims(::typeof(abs)) = (0, nothing)
# _visfunclims(::typeof(angle)) = (-π, π)
# _visfunclims(::typeof(rad2deg∘angle)) = (-180, 180)


DateTime() = AxFunc(label="Datetime", @o _.datetime)
Time() = AxFunc(label="Time of day", @o _.datetime |> Dates.Time)
baseline() = AxFunc(label="Baseline", x -> @p VLBI.antennas(x) map(_.name) join(__, " – "))
