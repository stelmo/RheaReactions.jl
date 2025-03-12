

"""
$(TYPEDSIGNATURES)

Return a cached metabolite, works in conjunction with [`get_reactions`](@ref).
"""
get_metabolites(mids) = [get_cache("metabolites", string(x)) for x in mids]

get_metabolite(mid) = get_cache("metabolites", string(mid))
