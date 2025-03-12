
quartet_body(rids) = """
PREFIX rh: <http://rdf.rhea-db.org/>

SELECT *
WHERE {
VALUES (?query) {
        $(join(["(rh:"*string(x)*")" for x in rids],"\n"))
    }
    { # if directional input
        ?ref rh:directionalReaction ?query ;
        rh:bidirectionalReaction ?bidir ;
        rh:directionalReaction ?dir .
    }
    UNION
    { # if bidirectional input
        ?ref rh:bidirectionalReaction ?query ;
        rh:bidirectionalReaction ?bidir ;
        rh:directionalReaction ?dir .
    }
    UNION
    { # if ref input
        ?query rh:directionalReaction ?dir ;
        rh:bidirectionalReaction ?bidir .
        ?ref rh:bidirectionalReaction ?bidir .
    }
}
"""

"""
$(TYPEDSIGNATURES)

Return all the quartets associated with reactions. NOT CACHED!
"""
function get_quartets(rids)
    rxns = RheaReactions.parse_request(RheaReactions.quartet_body(rids))
    qdict = Dict{String,Set{String}}()
    for rxn in rxns
        ref = RheaReactions.terminus(RheaReactions.double_get(rxn, "ref", "value"))
        d = get!(qdict, ref, Set{String}())
        push!(d, RheaReactions.terminus(RheaReactions.double_get(rxn, "bidir", "value")))
        push!(d, RheaReactions.terminus(RheaReactions.double_get(rxn, "dir", "value")))
        push!(d, RheaReactions.terminus(RheaReactions.double_get(rxn, "query", "value")))
        push!(d, ref)
    end
    qdict
end

get_quartet(rid; kwargs...) = get_quartets([rid])
