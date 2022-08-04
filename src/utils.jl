
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
    req = RheaReactions._request_data(args...; kwargs...)
    isnothing(req) && return nothing
    RheaReactions._parse_json(JSON.parse(String(req.body)))
end

"""
$(TYPEDSIGNATURES)

Get reaction data for Rhea id `rid`. Returns a dictionary mapping URIs to values.
"""
function get_reaction(rid::Int64)
    rxns = RheaReactions._parse_request(RheaReactions._reaction_body(rid))
    isnothing(rxns) && return nothing
    rxn = first(rxns)
    rr = RheaReaction()
    for rxn in rxns
        rr.id = parse(Int64, rxn["id"]["value"])
        rr.equation = rxn["eqn"]["value"]
        rr.status = rxn["status"]["value"]
        rr.accession = rxn["acc"]["value"]
        rr.name = RheaReactions._double_get(rxn, "name", "value")
        ec = RheaReactions._double_get(rxn, "ec", "value")
        !isnothing(ec) && (rr.ec = isnothing(rr.ec) ? [ec] : push!(rr.ec, ec))
        rr.istransport = rxn["istrans"]["value"] == "true"
        rr.isbalanced = rxn["isbal"]["value"] == "true"
    end
    return rr
end

"""
$(TYPEDSIGNATURES)

Return the reaction metabolite data of Rhea reaction id `rid`. 
"""
function get_reaction_metabolites(rid::Int64)
    compounds =
        RheaReactions._parse_request(RheaReactions._metabolite_stoichiometry_body(rid))
    compound_stoichs = Vector{Tuple{Float64,RheaMetabolite}}()
    for compound in compounds
        m = RheaMetabolite(
            parse(Int64, compound["id"]["value"]),
            compound["acc"]["value"],
            RheaReactions._double_get(compound, "name", "value"),
            parse(Int64, RheaReactions._double_get(compound, "charge", "value")),
            RheaReactions._double_get(compound, "formula", "value"),
        )
        coef =
            parse(Float64, compound["coef"]["value"]) *
            (endswith(compound["SoP"]["value"], "_L") ? -1.0 : 1.0)
        push!(compound_stoichs, (coef, m))
    end
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
    rxns = RheaReactions._parse_request(
        RheaReactions._reaction_metabolite_matches_body(substrate_ids, product_ids),
    )
    isnothing(rxns) && return nothing
    rr_rxns = Dict{Int64,RheaReaction}()
    for (i,rxn) in enumerate(rxns)
        println(i)
        id = parse(Int64, rxn["id"]["value"])
        if !haskey(rr_rxns, id)
            rr_rxns[id] = RheaReaction()
        end
        rr = rr_rxns[id]

        rr.id = parse(Int64, rxn["id"]["value"])
        rr.equation = rxn["eqn"]["value"]
        rr.status = rxn["status"]["value"]
        rr.accession = rxn["acc"]["value"]
        rr.name = RheaReactions._double_get(rxn, "name", "value")
        ec = RheaReactions._double_get(rxn, "ec", "value")
        !isnothing(ec) && (rr.ec = isnothing(rr.ec) ? [ec] : push!(rr.ec, ec))
        rr.istransport = rxn["istrans"]["value"] == "true"
        rr.isbalanced = rxn["isbal"]["value"] == "true"
    end
    return rr_rxns
end

"""
$(TYPEDSIGNATURES)

Return a dictionary of reactions where the ChEBI metabolite IDs in
`substrate_ids` and `product_ids` appear on opposite sides of the reaction.
Note, this is slow.
"""
function get_uniprot_to_rhea_map()
    elements = RheaReactions._parse_request(RheaReactions._uniprot_reviewed_rhea_mapping_body())
    uid_to_rhea = Dict{String, Vector{Int64}}()
    for element in elements
        uid = last(split(element["uniprot"]["value"], "/"))
        rid = parse(Int64, last(split(element["accession"]["value"], ":")))
        uid_to_rhea[uid] = push!(get(uid_to_rhea,uid, Int64[]), rid)
    end
    return uid_to_rhea
end