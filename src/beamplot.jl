@recipe BeamPoly (beam,) begin
    position=Point2(0.1, 0.1)
    Makie.MakieCore.documented_attributes(Makie.Poly)...
end

Makie.convert_arguments(ct::Type{<:BeamPoly}, beam::Beam) = convert_arguments(ct, ModelComponent(beam))

function Makie.plot!(p::BeamPoly{<:Tuple{ModelComponent}})
	scene = Makie.get_scene(p)
	center_data = lift(scene.camera.projectionview, p.model, Makie.transform_func(p), scene.viewport, p.position) do _, _, _, _, p
        Makie.project(scene.camera, :relative, :data, p)[1:2]
    end
    poly!(p, Makie.shared_attributes(p, Poly), @lift @modify(c -> c + $center_data, coords($(p.beam))))
    return p
end
