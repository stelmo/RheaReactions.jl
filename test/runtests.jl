using RheaReactions
using Test

@testset "RheaReactions.jl" begin
    clear_cache!()
    include("reactions.jl")
    include("metabolites.jl")
    include("reaction_matches.jl")
end
