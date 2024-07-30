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

# XXX: https://github.com/MakieOrg/Makie.jl/pull/3909
function __init__()
    if ccall(:jl_generating_output, Cint, ()) != 1
        @eval Makie function project(scenelike::SceneLike, input_space::Symbol, output_space::Symbol, pos::VecTypes{N, T1}) where {N, T1}
            T = promote_type(Float32, T1) # always float, maybe Float64
            input_space === output_space && return to_ndim(Point3{T}, pos, 0)
            cam = camera(scenelike)

            input_f32c = f32_convert_matrix(scenelike, input_space)
            clip_from_input = space_to_clip(cam, input_space)
            output_from_clip = clip_to_space(cam, output_space)
            output_f32c = inv_f32_convert_matrix(scenelike, output_space)

            p4d = to_ndim(Point4{T}, to_ndim(Point3{T}, pos, 0), 1)
            transformed = output_f32c * output_from_clip * clip_from_input * input_f32c * p4d
            return Point3{T}(transformed[Vec(1, 2, 3)] ./ transformed[4])
        end
    end
end
