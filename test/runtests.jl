using RheaReactions
using Test

@testset "RheaReactions.jl" begin
    clear_cache!()
    include("reactions.jl")
end
