module RheaReactions

using HTTP, JSON, DocStringExtensions, ReadableRegex

export get_reaction, get_metabolites_of_reaction

const endpoint_url = "https://sparql.rhea-db.org/sparql"
const compound_uri = "http://rdf.rhea-db.org/compound" 
const side_uri = "http://rdf.rhea-db.org/side"

"""
$TYPEDSIGNATURES

A simple SPARQL query that returns all the data matching `subject` from  the
Rhea endpoint. Returns `nothing` if the query errors. Can retry at most
`max_retries` before giving up. 
"""
function _request_data(subject::String; max_retries = 5)
    body = 
    """
        PREFIX rh: <http://rdf.rhea-db.org/>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        SELECT ?verb ?obj 
        WHERE {
            $subject ?verb ?obj .
        }
    """
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
                Dict("query" => body),
            )
        catch
            req = nothing
        end
    end
    return req
end

"""
$TYPEDSIGNATURES

Parse a json string returned by a rhea request into a dictionary.
"""
function _parse_json(unparsed_json)
    parsed_json = Dict{String, Vector{String}}()
    !haskey(unparsed_json, "results") && return parsed_json
    !haskey(unparsed_json["results"], "bindings") && return parsed_json
    
    for element in unparsed_json["results"]["bindings"]
        !haskey(element, "verb") || !haskey(element, "obj") && continue
        !haskey(element["verb"], "value") || !haskey(element["obj"], "value") && continue
        parsed_json[element["verb"]["value"]] = push!(get(parsed_json, element["verb"]["value"], String[]), element["obj"]["value"]) 
    end

    return parsed_json
end

"""
$TYPEDSIGNATURES

Combine [`_request_data`](@ref) with [`_parse_json`](@ref).
"""
function _parse_request(args...; kwargs...)
    req = RheaReactions._request_data(args...; kwargs...)
    isnothing(req) && return nothing
    RheaReactions._parse_json(JSON.parse(String(req.body)))
end

"""
$TYPEDSIGNATURES

Get reaction data for Rhea id `rid`. Returns a dictionary mapping URIs to values.
"""
get_reaction(rid::Int64) = RheaReactions._parse_request("rh:$rid")

"""
$TYPEDSIGNATURES

Return the reaction metabolite data of Rhea reaction id `rid`. 
"""
function get_metabolites_of_reaction(rid::Int64)
    r = Regex("contains" * one_or_more(DIGIT)) # does it contain stoichiometry entry
    compounds = Vector{Dict{String, Vector{String}}}()

    for LorR in ["_L", "_R"]
        side = RheaReactions._parse_request("rh:$rid"*LorR)
        isnothing(side) && return nothing
        for (side_key, side_values) in side
            sid = last(split(side_key, "/"))
            if occursin(r, sid)
                coeff = last(split(sid, "contains"))
                for reaction_participant_uri in side_values
                    reaction_participant = RheaReactions._parse_request("rh:"*last(split(reaction_participant_uri, "/")))
                    if haskey(reaction_participant, compound_uri)
                        compound =  RheaReactions._parse_request("rh:"*last(split(first(reaction_participant[compound_uri]), "/")))
                        compound["stoichiometric_coefficient"] = [coeff] 
                        compound["stoichiometric_coefficient"] = [LorR]
                        push!(compounds, compound)
                    end
                end
            end
        end
    end
    compounds
end

end
