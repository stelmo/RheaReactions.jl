module RheaReactions

using HTTP, JSON, DocStringExtensions, Term, Scratch, Serialization

# cache data using Scratch.jl
CACHE_LOCATION::String = ""
#=
Update these cache directories, this is where each cache type gets stored.
These directories are saved to in e.g. _cache("reaction", rid, rr) in utils.jl
=#
const CACHE_DIRS = ["reaction", "reaction_metabolites", "uniprot_reactions", "ec_reactions", "quartet"]

function __init__()
    global CACHE_LOCATION = @get_scratch!("rhea_data")

    for dir in CACHE_DIRS
        !isdir(joinpath(CACHE_LOCATION, dir)) && mkdir(joinpath(CACHE_LOCATION, dir))
    end

    if isfile(joinpath(CACHE_LOCATION, "version.txt"))
        vnum = read(joinpath(CACHE_LOCATION, "version.txt"))
        if String(vnum) != string(Base.VERSION)
            Term.tprint("""
                        {red} Caching uses Julia's serializer, which is incompatible
                        between different versions of Julia. Please clear the cache with
                        `clear_cache!()` before proceeding. {/red}
                        """)
        end
    else
        write(joinpath(CACHE_LOCATION, "version.txt"), string(Base.VERSION))
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
    get_reactions_with_ec,
    get_reactions_with_metabolites,
    get_reactions_with_uniprot_id,
    get_reaction_quartet,
    clear_cache!

end
