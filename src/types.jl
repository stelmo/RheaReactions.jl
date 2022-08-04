"""
$(TYPEDEF)

A struct for storing Rhea reaction information. Does not store the metabolite
information. 

$(FIELDS)
"""
struct RheaReaction
    id::Int64
    equation::String
    status::String
    accession::String
    name::Maybe{String}
    ec::Maybe{Vector{String}} # multiple ECs can be assigned to a single reaction
    istransport::Bool
    isbalanced::Bool
end

function Base.show(io::IO, ::MIME"text/plain", x::RheaReaction)
    text = "" 
    for fname in fieldnames(RheaReaction)
        text *= "{blue}$(string(fname)){/blue}: {purple}$(getfield(x, fname)){/purple}\n"
    end

    println(io, Panel(
            text,
            title="Rhea ID: $(x.id)",
            title_style="bold green",
            style="gold1 bold",
            fit=true,
            justify=:left,
        )
    )
end

"""
$(TYPEDEF)

A struct for storing Rhea metabolite information.

$(FIELDS)
"""
struct RheaMetabolite
    id::Int64
    accession::String
    name::Maybe{String}
    charge::Maybe{Int64}
    formula::Maybe{String}
end

function Base.show(io::IO, ::MIME"text/plain", x::RheaMetabolite)
    text = "" 
    for fname in fieldnames(RheaMetabolite)
        text *= "{blue}$(string(fname)){/blue}: {purple}$(getfield(x, fname)){/purple}\n"
    end
    chebi = last(split(x.accession, "/"))
    println(io, Panel(
            text,
            title="ChEBI ID: $(chebi)",
            title_style="bold green",
            style="gold1 bold",
            fit=true,
            justify=:left,
        )
    )
end

function Base.show(io::IO, ::MIME"text/plain", x::Vector{Tuple{Float64, RheaMetabolite}})    
    substrates = String[]
    products = String[]
    for (coef, compound) in x 
        if coef < 0 # substrate
            push!(substrates, "$(abs(coef)) {purple}$(compound.name){/purple}")
        else # product
            push!(products, "$(abs(coef)) {purple}$(compound.name){/purple}")
        end
    end


    println(io, Panel(
            join(substrates, " {blue}+{/blue} ") * " {red}={/red} " * join(products, " {blue}+{/blue} "),
            title="Reaction scheme",
            title_style="bold green",
            style="gold1 bold",
            fit=true,
            justify=:center,
        )
    )
end

