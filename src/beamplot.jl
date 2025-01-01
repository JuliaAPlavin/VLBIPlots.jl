beampoly!(ax::Axis, b::ModelComponent; centerax, kwargs...) = 
    poly!(
        ax,
        @lift begin
            lo = SVector($(ax.finallimits).origin)
            ws = SVector($(ax.finallimits).widths)
            center_data = lo + SVector(centerax) .* ws
            @modify(c -> c + center_data, coords(b))
        end;
        kwargs...
    )
