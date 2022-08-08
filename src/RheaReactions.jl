module RheaReactions

using HTTP, JSON, DocStringExtensions, Term

const Maybe{T} = Union{T,Nothing}
const endpoint_url = "https://sparql.rhea-db.org/sparql"

include("types.jl")
include("sparql.jl")
include("utils.jl")

export get_reaction, get_reaction_metabolites, RheaReaction, RheaMetabolite, get_reactions_with_ec

end
