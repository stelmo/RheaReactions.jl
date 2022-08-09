
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

Note, charge defaults to `nothing` if an unexpected input is encountered.
Likewise, the stoichiometric coefficient defaults to `999` if a non-numeric
input is encountered. It does not return `nothing`, since the coefficient is
also used to store if the metabolite is a substrate or product. These cases crop
up with polymeric reactions. 
"""
function get_reaction_metabolites(rid::Int64; should_cache = true)
    _is_cached("reaction_metabolites", rid) &&
        return _get_cache("reaction_metabolites", rid)

    rids = get_reaction_quartet(rid)
    compounds = []
    for rid in rids # the sparql query only works with the reference reaction, not the directional ones
        compounds = RheaReactions._parse_request(RheaReactions._metabolite_stoichiometry_body(rid))
        !isnothing(compounds) && break
    end

    isnothing(compounds) && return nothing

    compound_stoichs = Vector{Tuple{Float64, RheaMetabolite}}();
    for compound in compounds
        _charge = RheaReactions._double_get(compound, "charge", "value") # could be nothing
        #= 
        Polymeric compounds return charge as a function of n, ignore these.
        This implementation then assumes the charge of a compound is never higher/lower than ±9.
        =#
        charge = isnothing(_charge) || length(_charge) != 1 ? nothing : parse(Int64, _charge) 
        m = RheaMetabolite(
            parse(Int64, compound["id"]["value"]),
            compound["acc"]["value"],
            RheaReactions._double_get(compound, "name", "value"),
            charge,
            RheaReactions._double_get(compound, "formula", "value"),
        )
        #=
        If coefficient is N or N+1, then return 999 with the sign denoting substrate or product. 
        =#
        _coef = startswith("N", compound["coef"]["value"]) ? "999" : compound["coef"]["value"]         
        coef = parse(Float64, _coef) * (endswith(compound["SoP"]["value"], "_L") ? -1.0 : 1.0)
        
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

Return the accession number associated with each element in `elements`.
"""
function _get_accessions(elements)
    xs = Int64[]
    for element in elements
        x = _double_get(element, "accession", "value")
        isnothing(x) && continue
        push!(xs, parse(Int64, last(split(x, ":"))))
    end
    return xs
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
    
    uid_to_rhea = _get_accessions(elements)

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

    ec_to_rheas = _get_accessions(elements)

    should_cache && _cache("ec_reactions", ec, ec_to_rheas)

    return ec_to_rheas
end


"""
$(TYPEDSIGNATURES)

Return a list of the reference, directional (x2), and bidirectional reactions
associated with `rid`. This is useful if you want to find the reactions 
catalyzing the same transformation, but with different directions.
"""
function get_reaction_quartet(rid::Int64; should_cache = true)
    _is_cached("quartet", rid) && return _get_cache("quartet", rid)

    ref_solution = -1
    
    elements = RheaReactions._parse_request(RheaReactions._from_directional_reaction(rid))
    if !isnothing(elements)
        ref_solution = first(RheaReactions._get_accessions(elements))
    end

    elements = RheaReactions._parse_request(RheaReactions._from_bidirectional_reaction(rid))
    if !isnothing(elements)
        ref_solution = first(RheaReactions._get_accessions(elements))
    end
    
    ref_solution = ref_solution == -1 ? rid : ref_solution
    
    elements = RheaReactions._parse_request(RheaReactions._from_reference_reaction(ref_solution))
    other_rxns = RheaReactions._get_accessions(elements)
    quartet = [ref_solution; other_rxns] 

    should_cache && _cache("quartet", rid, quartet)
    
    return quartet
end