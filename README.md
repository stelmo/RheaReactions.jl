# RheaReactions

This is a simple package you can use to query Rhea reactions:
```julia
rxn = get_reaction(11364) # Rhea reaction ID 11364
```
You can also get the metabolites associated with that reaction:
```julia
coeff_mets = get_reaction_metabolites(11364) # (coefficient, metabolite)
```
And look at each metabolite individually:
```julia
coeff_mets[1][2] # metabolite
```
