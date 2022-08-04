
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
    RheaReaction(
        parse(Int64, first(rxns)["id"]["value"]),
        first(rxns)["eqn"]["value"],
        first(rxns)["status"]["value"],
        first(rxns)["acc"]["value"],
        RheaReactions._double_get(first(rxns), "name", "value"),
        [RheaReactions._double_get(rxn, "ec", "value") for rxn in rxns],
        first(rxns)["istrans"]["value"] == "true",
        first(rxns)["isbal"]["value"] == "true",
    )
end


"""
$(TYPEDSIGNATURES)

Return the reaction metabolite data of Rhea reaction id `rid`. 
"""
function get_reaction_metabolites(rid::Int64)
    compounds =
        RheaReactions._parse_request(RheaReactions._metabolite_stoichiometry_body(rid))
    compound_stoichs = Vector{Tuple{Float64, RheaMetabolite}}()
    for compound in compounds
        m = RheaMetabolite(
            parse(Int64, compound["id"]["value"]),
            compound["acc"]["value"],
            RheaReactions._double_get(compound, "name", "value"),
            parse(Int64, RheaReactions._double_get(compound, "charge", "value")),
            RheaReactions._double_get(compound, "formula", "value"),
        )
        coef = parse(Float64, compound["coef"]["value"]) * (endswith(compound["SoP"]["value"], "_L") ? -1.0 : 1.0)
        push!(compound_stoichs, (coef, m))
    end
    return compound_stoichs
end