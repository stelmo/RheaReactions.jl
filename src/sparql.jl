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