module RheaReactions

using HTTP, JSON, DocStringExtensions, Term, Scratch, Serialization

# cache data using Scratch.jl
CACHE_LOCATION::String = ""
#=
Update these cache directories, this is where each cache type gets stored.
These directories are saved to in e.g. _cache("reaction", rid, rr) in utils.jl
=#
const CACHE_DIRS = ["reactions", "metabolites"]

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
include("utils.jl")
include("reactions.jl")
include("metabolites.jl")
include("quartets.jl")

export clear_cache!, get_reaction, get_reactions, get_metabolite, get_metabolites, get_quartet, get_quartets


end
