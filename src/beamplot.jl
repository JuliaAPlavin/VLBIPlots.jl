@recipe(Beampoly, beam) do scene
    Attributes(
        position=Point2(0.1, 0.1),
    )
end

Makie.convert_arguments(ct::Type{<:Beampoly}, beam::Beam) = convert_arguments(ct, ModelComponent(beam))

function Makie.plot!(p::Beampoly{<:Tuple{ModelComponent}})
    poly!(p, Makie.shared_attributes(p, Poly),
        @lift let
            center_data = Makie.fractionpoint(
                convert(Rect2f, $(Makie.projview_to_2d_limits(p))),
                convert(Point2, $(p.position))
            )
            @modify(c -> c + center_data, coords($(p.beam)))
        end
    )
    return p
end
