# RheaReactions
[repostatus-url]: https://www.repostatus.org/#active
[repostatus-img]: https://www.repostatus.org/badges/latest/active.svg

[![repostatus-img]][repostatus-url]

This is a simple package you can use to query Rhea reactions:
```julia
get_reaction(11364) # Rhea reaction ID 11364
```
You can also get the metabolites associated with that reaction:
```julia
coeff_mets = get_reaction_metabolites(11364) # [(coefficient, metabolite), ...] but has pretty printing that hides this structure
```
And look at each metabolite individually:
```julia
coeff_mets[1][2] # metabolite
```
You can also look for all reactions that have a certain set of metabolite
substrates and products. This function looks for reactions that have both
CHEBI:29985 (L-glutamate) and CHEBI:58359 (L-glutamine) to be on opposite sides
of the reaction:
```julia
substrate_ids = [29985,]
product_ids = [58359,]
RheaReactions.get_reactions_with_metabolites(
    substrate_ids,
    product_ids,
)
```
You can also map the entire reviewed Uniprot IDs to Rhea reaction IDs, although this takes long:
```julia
get_uniprot_to_rhea_map()
```
You can test the package with:
```julia
] test
```

