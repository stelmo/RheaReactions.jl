"""
$(TYPEDSIGNATURES)

Clear the entire cache.
"""
clear_cache!() = begin
    for dir in readdir(CACHE_LOCATION)
        rm(joinpath(CACHE_LOCATION, dir), recursive = true)
        dir != "version.txt" && mkdir(joinpath(CACHE_LOCATION, dir)) # add back the empty dir
    end
    write(joinpath(CACHE_LOCATION, "version.txt"), string(Base.VERSION))
    @info "Cache cleared"
end

"""
$(TYPEDSIGNATURES)

Checks if the reaction has been cached.
"""
is_cached(database::String, id) =
    isfile(joinpath(RheaReactions.CACHE_LOCATION, database, string(id)))

"""
$(TYPEDSIGNATURES)

Return the cached reaction object.
"""
get_cache(database::String, id) =
    deserialize(joinpath(CACHE_LOCATION, database, string(id)))

"""
$(TYPEDSIGNATURES)

Cache reaction object.
"""
cache(database::String, id, item) =
    serialize(joinpath(CACHE_LOCATION, database, string(id)), item)
