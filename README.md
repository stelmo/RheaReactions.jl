# RheaReactions
[repostatus-url]: https://www.repostatus.org/#active
[repostatus-img]: https://www.repostatus.org/badges/latest/active.svg

[![repostatus-img]][repostatus-url]

This is a simple package you can use to query Rhea reactions:
```julia
rxn = get_reaction(11364) # Rhea reaction ID 11364
```
You can also get the metabolites associated with that reaction:
```julia
coeff_mets = get_reaction_metabolites(11364) # [(coefficient, metabolite), ...] but has pretty printing that hides this structure
```
And look at each metabolite individually:
```julia
coeff_mets[1][2] # metabolite
```
You can test the package with:
```julia
] test
```

