"""
$(TYPEDSIGNATURES)

Clear the entire cache.
"""
clear_cache!() = begin     
    rm(joinpath(cache_location, "reactions"), recursive=true)
    rm(joinpath(cache_location, "reaction_metabolites"), recursive=true)
end

"""
$(TYPEDSIGNATURES)

Checks if the reaction has been cached.
"""
_is_cached_reaction(rid::Int64) =
    isfile(joinpath(RheaReactions.cache_location, "reactions", "rxn_$rid.jls"))

"""
$(TYPEDSIGNATURES)

Return the cached reaction object.
"""
_get_cached_reaction(rid::Int64) =
    deserialize(joinpath(cache_location, "reactions", "rxn_$rid.jls"))

"""
$(TYPEDSIGNATURES)

Cache reaction object.
"""
_cache_reaction(rid::Int64, rxn::RheaReaction) =
    serialize(joinpath(cache_location, "reactions", "rxn_$rid.jls"), rxn)

"""
$(TYPEDSIGNATURES)

Checks if the reaction metabolite data has been cached.
"""
_is_cached_reaction_metabolites(rid::Int64) =
    isfile(joinpath(cache_location, "reaction_metabolites", "rxn_$rid.jls"))

"""
$(TYPEDSIGNATURES)

Return the cached reaction metabolites object.
"""
_get_cached_reaction_metabolites(rid::Int64) =
    deserialize(joinpath(cache_location, "reaction_metabolites", "rxn_$rid.jls"))

_cache_reaction_metabolites(rid::Int64, rxnmets) =
    serialize(joinpath(cache_location, "reaction_metabolites", "rxn_$rid.jls"), rxnmets)
