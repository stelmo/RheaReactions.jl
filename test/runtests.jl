using RheaReactions
using Test

@testset "RheaReactions.jl" begin
    include("reactions.jl")
    include("metabolites.jl")
    include("reaction_matches.jl")
end
