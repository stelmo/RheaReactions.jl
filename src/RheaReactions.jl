module RheaReactions

using HTTP, JSON

const endpoint_url = "https://sparql.rhea-db.org/sparql"

function request_data(subject::String; max_retries = 5)
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

function get_reaction(rid::Int64)
    rxn_outer_req = Rhea.request_data("rh:$rid")
    isnothing(rxn_outer_req) && return nothing
    rxn_outer = Rhea.parse_json(JSON.parse(String(rxn_outer_req.body)))

    if haskey(rxn_outer, "http://rdf.rhea-db.org/side")
        sides = rxn_outer["http://rdf.rhea-db.org/side"]
        L_idx = findfirst(endswith("_L"), sides)
        R_idx = findfirst(endswith("_R"), sides)
        
        if !isnothing(L_idx) && !isnothing(R_idx)
            left_side_req = Rhea.request_data("rh:"*last(split(sides[L_idx],"/")))
            left_side = Rhea.parse_json(JSON.parse(String(left_side_req.body)))



            right_side_req = Rhea.request_data("rh:"*last(split(sides[R_idx],"/")))
            left_side = Rhea.parse_json(JSON.parse(String(right_side_req.body)))
        end
    end
end

function parse_json(unparsed_json)
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

end
