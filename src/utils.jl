
"""
$(TYPEDSIGNATURES)

Shortcut for `get(get(dict, key1, Dict()), key2, nothing)`.
"""
_double_get(dict, key1, key2; default = nothing) =
    get(get(dict, key1, Dict()), key2, default)

"""
$(TYPEDSIGNATURES)

A simple SPARQL query that returns all the data matching `query` from  the
Rhea endpoint. Returns `nothing` if the query errors. Can retry at most
`max_retries` before giving up. 
"""
function _request_data(query; max_retries = 5)
    retry_counter = 0
    req = nothing
    while retry_counter <= max_retries
        retry_counter += 1
        try
            req = HTTP.request(
                "POST",
                endpoint_url,
                [
                    "Accept" => "application/sparql-results+json",
                    "Content-type" => "application/x-www-form-urlencoded",
                ],
                Dict("query" => query),
            )
        catch
            req = nothing
        end
    end
    return req
end

"""
$(TYPEDSIGNATURES)

Parse a json string returned by a rhea request into a dictionary.
"""
function _parse_json(unparsed_json)
    parsed_json = Dict{String,Vector{String}}()
    !haskey(unparsed_json, "results") && return parsed_json
    !haskey(unparsed_json["results"], "bindings") && return parsed_json
    unparsed_json["results"]["bindings"]
end

"""
$(TYPEDSIGNATURES)

Combine [`_request_data`](@ref) with [`_parse_json`](@ref).
"""
function _parse_request(args...; kwargs...)
    req = _request_data(args...; kwargs...)
    isnothing(req) && return nothing
    preq = _parse_json(JSON.parse(String(req.body)))
    isempty(preq) ? nothing : preq
end

"""
$(TYPEDSIGNATURES)

Get reaction data for Rhea id `rid`. Returns a dictionary mapping URIs to
values.  This function is cached automatically by default, use `should_cache` to
change this behavior.
"""
function get_reaction(rid::Int64; should_cache = true)
    _is_cached("reaction", rid) && return _get_cache("reaction", rid)

    rxns = _parse_request(_reaction_body(rid))
    isnothing(rxns) && return nothing
    rxn = first(rxns)
    rr = RheaReaction()
    for rxn in rxns
        rr.id = parse(Int64, rxn["id"]["value"])
        rr.equation = rxn["eqn"]["value"]
        rr.status = rxn["status"]["value"]
        rr.accession = rxn["acc"]["value"]
        rr.name = _double_get(rxn, "name", "value")
        ec = _double_get(rxn, "ec", "value")
        !isnothing(ec) && (rr.ec = isnothing(rr.ec) ? [ec] : push!(rr.ec, ec))
        rr.istransport = rxn["istrans"]["value"] == "true"
        rr.isbalanced = rxn["isbal"]["value"] == "true"
    end

    should_cache && _cache("reaction", rid, rr)

    return rr
end

"""
$(TYPEDSIGNATURES)

Return the reaction metabolite data of Rhea reaction id `rid`. This function is
cached automatically by default, use `should_cache` to change this behavior. 
"""
function get_reaction_metabolites(rid::Int64; should_cache = true)
    _is_cached("reaction_metabolites", rid) &&
        return _get_cache("reaction_metabolites", rid)

    compounds = _parse_request(_metabolite_stoichiometry_body(rid))
    isnothing(compounds) && return nothing

    compound_stoichs = Vector{Tuple{Float64,RheaMetabolite}}()
    for compound in compounds
        m = RheaMetabolite(
            parse(Int64, compound["id"]["value"]),
            compound["acc"]["value"],
            _double_get(compound, "name", "value"),
            parse(Int64, _double_get(compound, "charge", "value")),
            _double_get(compound, "formula", "value"),
        )
        coef =
            parse(Float64, compound["coef"]["value"]) *
            (endswith(compound["SoP"]["value"], "_L") ? -1.0 : 1.0)
        push!(compound_stoichs, (coef, m))
    end

    should_cache && _cache("reaction_metabolites", rid, compound_stoichs)

    return compound_stoichs
end

"""
$(TYPEDSIGNATURES)

Return a dictionary of reactions where the ChEBI metabolite IDs in
`substrate_ids` and `product_ids` appear on opposite sides of the reaction.
"""
function get_reactions_with_metabolites(
    substrate_ids::Vector{Int64},
    product_ids::Vector{Int64},
)
    rxns = _parse_request(_reaction_metabolite_matches_body(substrate_ids, product_ids))
    isnothing(rxns) && return nothing
    rr_rxns = Dict{Int64,RheaReaction}()
    for rxn in rxns
        id = parse(Int64, rxn["id"]["value"])
        if !haskey(rr_rxns, id)
            rr_rxns[id] = RheaReaction()
        end
        rr = rr_rxns[id]

        rr.id = parse(Int64, rxn["id"]["value"])
        rr.equation = rxn["eqn"]["value"]
        rr.status = rxn["status"]["value"]
        rr.accession = rxn["acc"]["value"]
        rr.name = _double_get(rxn, "name", "value")
        ec = _double_get(rxn, "ec", "value")
        !isnothing(ec) && (rr.ec = isnothing(rr.ec) ? [ec] : push!(rr.ec, ec))
        rr.istransport = rxn["istrans"]["value"] == "true"
        rr.isbalanced = rxn["isbal"]["value"] == "true"
    end

    return rr_rxns
end

"""
$(TYPEDSIGNATURES)

Return a list of reactions that are associated with the Uniprot ID `uniprot_id`.
"""
function get_reactions_with_uniprot_id(uniprot_id::String; should_cache = true)
    _is_cached("uniprot_reactions", uniprot_id) &&
        return _get_cache("uniprot_reactions", uniprot_id)

    elements = _parse_request(_uniprot_reviewed_rhea_mapping_body(uniprot_id))
    isnothing(elements) && return nothing

    uid_to_rhea = Int64[]
    for element in elements
        x = _double_get(element, "accession", "value")
        isnothing(x) && continue
        push!(uid_to_rhea, parse(Int64, last(split(x, ":"))))
    end

    should_cache && _cache("uniprot_reactions", uniprot_id, uid_to_rhea)

    return uid_to_rhea
end

"""
$(TYPEDSIGNATURES)

Return a list of all Rhea reaction IDs that map to a specific EC number `ec`.
"""
function get_reactions_with_ec(ec::String; should_cache = true)
    _is_cached("ec_reactions", ec) && return _get_cache("ec_reactions", ec)

    elements = _parse_request(_ec_rhea_mapping_body(ec))
    isnothing(elements) && return nothing

    ec_to_rheas = Int64[]
    for element in elements
        x = _double_get(element, "accession", "value")
        isnothing(x) && continue
        push!(ec_to_rheas, parse(Int64, last(split(x, ":"))))
    end

    should_cache && _cache("ec_reactions", ec, ec_to_rheas)

    return ec_to_rheas
end
