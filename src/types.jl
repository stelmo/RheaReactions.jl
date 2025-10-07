"""
$(TYPEDEF)

A struct for storing Rhea reaction information. Does not store the metabolite
information. 

$(FIELDS)
"""
mutable struct RheaReaction
    id::String # rhea ID
    equation::Maybe{String}
    stoichiometry::Dict{String,Float64} # chebi id => coefficient
end

RheaReaction(id) = RheaReaction(id, nothing, Dict{String,Float64}())

"""
$(TYPEDEF)

A struct for storing Rhea metabolite information.

$(FIELDS)
"""
mutable struct RheaMetabolite
    id::String # chebi ID
    name::Maybe{String}
    charge::Maybe{Int64}
    formula::Maybe{String}
    inchi::Maybe{String}
    inchikey::Maybe{String}
    smiles::Maybe{String}
end

RheaMetabolite(id) =
    RheaMetabolite(id, nothing, nothing, nothing, nothing, nothing, nothing)
