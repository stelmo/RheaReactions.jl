#=
SPARQL queries

Thanks Mirek for helping!
=#

"""
$(TYPEDSIGNATURES)

Construct a SPARQL query for retrieving reaction information of reaction `rid`,
which is the Rhea ID.
"""
_reaction_body(rid::Int64) = """
PREFIX rh: <http://rdf.rhea-db.org/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT *
WHERE {
	 rh:$rid rh:id ?id ;
     	rh:equation ?eqn ;
        rh:accession ?acc ;
  		rh:status ?status .
	OPTIONAL {rh:$rid rh:name ?name }.
	OPTIONAL {rh:$rid rh:ec ?ec }.
  	OPTIONAL {rh:$rid rh:isTransport ?istrans}.
   	OPTIONAL {rh:$rid rh:isChemicallyBalanced ?isbal }.
}
"""

"""
$(TYPEDSIGNATURES)

Construct a SPARQL query for retrieving the metabolites involved with reaction
`rid`, which is the Rhea ID.
"""
_metabolite_stoichiometry_body(rid::Int64) = """
PREFIX rh: <http://rdf.rhea-db.org/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT *
WHERE {
    { rh:$rid rh:bidirectionalReaction / rh:substratesOrProducts ?SoP } .
    ?SoP ?contains [rh:compound ?cmp] . 
    ?contains rh:coefficient ?coef .
    ?cmp rh:id ?id ; 
        rh:accession ?acc .
    OPTIONAL {?cmp rh:charge ?charge}.
    OPTIONAL {?cmp rh:name ?name}. 
    OPTIONAL {?cmp rh:formula ?formula}.
}
"""

"""
$(TYPEDSIGNATURES)

Construct a SPARQL query that finds Rhea reactions with 
"""
function _reaction_metabolite_matches_body(
    substrate_ids::Vector{Int64},
    product_ids::Vector{Int64},
)

    substrates = join(
        [
            """
            VALUES (?chebi_s$idx) { (CHEBI:$id) }
            OPTIONAL { ?chebi_s$idx up:name ?name_s$idx} .
            ?rhea rh:side ?reactionSide_S .
            ?rhea rh:accession ?acc_s$idx .
            ?reactionSide_S  rh:contains / rh:compound / rh:chebi ?chebi_s$idx .
            """ for (idx, id) in enumerate(substrate_ids)
        ],
        "\n",
    )

    products = join(
        [
            """
            VALUES (?chebi_p$idx) { (CHEBI:$id) }
            OPTIONAL { ?chebi_p$idx up:name ?name_p$idx }.
            ?rhea rh:side ?reactionSide_P .
            ?rhea rh:accession ?acc_p$idx .
            ?reactionSide_P  rh:contains / rh:compound / rh:chebi ?chebi_p$idx .
            """ for (idx, id) in enumerate(product_ids)
        ],
        "\n",
    )

    """
    PREFIX rh: <http://rdf.rhea-db.org/>
    PREFIX CHEBI: <http://purl.obolibrary.org/obo/CHEBI_>
    PREFIX up: <http://purl.uniprot.org/core/>
    
    SELECT *
    WHERE {
        $substrates
    
        $products
        
        ?reactionSide_S rh:transformableTo ?reactionSide_P .
      
        ?rhea rh:equation ?eqn ;
            rh:status ?status ;
            rh:id ?id ;
            rh:accession ?acc .
        OPTIONAL {?rhea rh:name ?name }.
        OPTIONAL {?rhea rh:ec ?ec }.
        OPTIONAL {?rhea rh:isTransport ?istrans}.
        OPTIONAL {?rhea rh:isChemicallyBalanced ?isbal }.
    }
    """
end

"""
$(TYPEDSIGNATURES)

Return a mapping between uniprot IDs and Rhea reaction IDs.
"""
_uniprot_reviewed_rhea_mapping_body(uid::String) = """
PREFIX rh: <http://rdf.rhea-db.org/>
PREFIX up: <http://purl.uniprot.org/core/>
SELECT * 
WHERE {
  SERVICE <https://sparql.uniprot.org/sparql> { 
    <http://purl.uniprot.org/uniprot/$uid> up:annotation/up:catalyticActivity/up:catalyzedReaction ?rhea . 
  }
  ?rhea rh:accession ?accession .
}
"""

_ec_rhea_mapping_body(ec::String) = """
PREFIX rh: <http://rdf.rhea-db.org/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ec: <http://purl.uniprot.org/enzyme/>

SELECT ?ec ?rhea ?accession 
WHERE {
  ?rhea rdfs:subClassOf rh:Reaction .
  ?rhea rh:accession ?accession .
  ?rhea rh:ec ?ec;
  rh:ec <http://purl.uniprot.org/enzyme/$ec> .
}
"""
