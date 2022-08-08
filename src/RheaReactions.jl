module RheaReactions

using HTTP, JSON, DocStringExtensions, Term, Scratch, Serialization

# cache data using Scratch.jl
cache_location = ""

function __init__()
    global cache_location = @get_scratch!("rhea_data")
    
    !isdir(joinpath(cache_location, "reactions")) && mkdir(joinpath(cache_location, "reactions"))
    !isdir(joinpath(cache_location, "reaction_metabolites")) && mkdir(joinpath(cache_location, "reaction_metabolites"))

    if isfile(cache_location, "version.txt")
        vnum = read(joinpath(cache_location, "version.txt"))
        if String(vnum) != string(Base.VERSION)
            Term.tprint(
                """
                {red} Caching uses Julia's serializer, which is incompatible
                between different versions of Julia. Please clear the cache with
                `clear_cache!()` before proceeding. {/red}
                """
            )
        end
    else
        write(joinpath(cache_location, "version.txt"), string(Base.VERSION))
    end
end

const Maybe{T} = Union{T,Nothing}
const endpoint_url = "https://sparql.rhea-db.org/sparql"

include("types.jl")
include("cache.jl")
include("sparql.jl")
include("utils.jl")

export get_reaction,
    get_reaction_metabolites,
    RheaReaction,
    RheaMetabolite,
    get_reactions_with_ec,
    get_reactions_with_metabolites,
    clear_cache!

end
