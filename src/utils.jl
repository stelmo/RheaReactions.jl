
"""
$(TYPEDSIGNATURES)

Shortcut for `get(get(dict, key1, Dict()), key2, nothing)`.
"""
double_get(dict, key1, key2; default = nothing) =
    get(get(dict, key1, Dict()), key2, default)

"""
$(TYPEDSIGNATURES)

A simple SPARQL query that returns all the data matching `query` from  the
Rhea endpoint. Returns `nothing` if the query errors. Can retry at most
`max_retries` before giving up. 
"""
function request_data(query; max_retries = 5)
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
function parse_json(unparsed_json)
    parsed_json = Dict{String,Vector{String}}()
    !haskey(unparsed_json, "results") && return parsed_json
    !haskey(unparsed_json["results"], "bindings") && return parsed_json
    unparsed_json["results"]["bindings"]
end

"""
$(TYPEDSIGNATURES)

Combine [`request_data`](@ref) with [`parse_json`](@ref).
"""
function parse_request(args...; kwargs...)
    req = request_data(args...; kwargs...)
    isnothing(req) && return nothing
    preq = parse_json(JSON.parse(String(req.body)))
    isempty(preq) ? nothing : preq
end

"""
$(TYPEDSIGNATURES)

Get the last part of a path.
"""
terminus(p::String, d = "/") = String(last(split(p, d)))

"""
$(TYPEDSIGNATURES)

Get the version of Julia that was used to generate the serialized files.
"""
getserializedversion() = String(read(joinpath(CACHE_LOCATION, "version.txt")))

