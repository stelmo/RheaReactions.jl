"""
$(TYPEDEF)

A struct for storing Rhea reaction information. Does not store the metabolite
information. 

$(FIELDS)
"""
@with_repr mutable struct RheaReaction
    id::Int64
    equation::String
    status::String
    accession::String
    name::Maybe{String}
    ec::Maybe{Vector{String}} # multiple ECs can be assigned to a single reaction
    istransport::Bool
    isbalanced::Bool
end

RheaReaction() = RheaReaction(0, "", "", "", nothing, nothing, false, false)

"""
$(TYPEDEF)

A struct for storing Rhea metabolite information.

$(FIELDS)
"""
@with_repr struct RheaMetabolite
    id::Int64
    accession::String
    name::Maybe{String}
    charge::Maybe{Int64}
    formula::Maybe{String}
end

