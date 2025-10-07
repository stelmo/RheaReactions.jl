#=
This is the core information that you need to construct a reaction. 
Use other sparql queries to get more annotation info for reactions.
=#
reactions_body(rids) = """
PREFIX rh: <http://rdf.rhea-db.org/>
PREFIX ch: <http://purl.obolibrary.org/obo/chebi/>

SELECT *
WHERE {
  VALUES (?rhea) {
    $(join(["(rh:"*string(x)*")" for x in rids],"\n"))
  }
  ?rhea (rh:side|rh:substrates|rh:products|rh:substratesOrProducts) ?side ;
        rh:equation ?eq .
  ?side rh:contains ?part .
  ?part (rh:compound|(rh:compound/rh:reactivePart)) ?compound .
  ?side ?cc ?part .
  ?cc rh:coefficient ?coeff .
  ?compound rh:chebi ?chebi ;
            rh:formula ?formula ;
            rh:charge ?charge ;
            rh:name ?name .
  OPTIONAL { ?chebi ch:inchikey ?ikey ;
         ch:smiles ?smiles ;
         ch:inchi ?inchi . } .
}
"""

"""
$(TYPEDSIGNATURES)

Return a vector of [`RheaReaction`](@ref)s. Implicitly cache metabolites.
"""
function get_reactions(rids)
    rids = string.(rids)

    rrs = RheaReactions.RheaReaction[]
    append!(
        rrs,
        [
            get_cache("reactions", x) for
            x in rids if RheaReactions.is_cached("reactions", x)
        ],
    )

    uncached_rids = [x for x in rids if !RheaReactions.is_cached("reactions", x)]
    isempty(uncached_rids) && return rrs
    
    rxns = RheaReactions.parse_request(RheaReactions.reactions_body(uncached_rids))
    isnothing(rxns) && return nothing

    rdict = Dict{String,RheaReactions.RheaReaction}()
    mdict = Dict{String,RheaReactions.RheaMetabolite}()
    for rxn in rxns
        rid = RheaReactions.terminus(rxn["rhea"]["value"])
        rr = get!(rdict, rid, RheaReactions.RheaReaction(rid))
        rr.equation = RheaReactions.double_get(rxn, "eq", "value")
        chebi = RheaReactions.terminus(rxn["chebi"]["value"], "_")
        rr.stoichiometry[chebi] =
            get(rr.stoichiometry, chebi, 0) +
            (RheaReactions.terminus(rxn["side"]["value"], "_") == "R" ? 1.0 : -1.0) *
            parse(Int, rxn["coeff"]["value"])

        if !haskey(mdict, chebi)
            rm = get!(mdict, chebi, RheaReactions.RheaMetabolite(chebi))
            rm.name = RheaReactions.double_get(rxn, "name", "value")
            rm.formula = RheaReactions.double_get(rxn, "formula", "value")
            rm.charge = parse(Int, RheaReactions.double_get(rxn, "charge", "value"))
            rm.inchi = RheaReactions.double_get(rxn, "inchi", "value")
            rm.inchikey = RheaReactions.double_get(rxn, "ikey", "value")
            rm.smiles = RheaReactions.double_get(rxn, "smiles", "value")
        end
    end

    for (k, v) in rdict
        RheaReactions.cache("reactions", k, v)
        push!(rrs, v)
    end
    for (k, v) in mdict
        RheaReactions.is_cached("metabolites", k) || RheaReactions.cache("metabolites", k, v)
    end

    rrs
end

get_reaction(rid; kwargs...) = first(get_reactions([rid]; kwargs...))
