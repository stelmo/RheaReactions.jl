# RheaReactions.jl
[repostatus-url]: https://www.repostatus.org/#active
[repostatus-img]: https://www.repostatus.org/badges/latest/active.svg

[ci-img]: https://github.com/stelmo/RheaReactions.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/stelmo/RheaReactions.jl/actions/workflows/ci.yml

[cov-img]: https://codecov.io/gh/stelmo/RheaReactions.jl/branch/master/graph/badge.svg?token=R71TrrfMmS
[cov-url]: https://codecov.io/gh/stelmo/RheaReactions.jl

| **Tests** | **Coverage** | **Project status** |
|:---:|:---:|:---:|
| [![CI status][ci-img]][ci-url] | [![codecov][cov-img]][cov-url] | [![repostatus-img]][repostatus-url] |

This is a simple package you can use to query Rhea reactions and associated
annotations. Its primary use is in reconstructing metabolic models. It caches
all requests by default, speeding up repeated calls where appropriate.
```julia
using RheaReactions # load module

get_reaction(11364) # Rhea reaction ID 11364
```
You can also get the metabolites associated with that reaction:
```julia
# [(coefficient, metabolite), ...] 
coeff_mets = get_reaction_metabolites(11364) # Rhea reaction ID 11364
```
And look at each metabolite individually:
```julia
coeff_mets[1][2] # metabolite
```
You can also look for all reactions that have a certain set of metabolite
substrates and products. This function looks for all reactions that have both
CHEBI:29985 (L-glutamate) and CHEBI:58359 (L-glutamine) on opposite sides
of the reaction:
```julia
substrate_ids = [29985,]
product_ids = [58359,]
get_reactions_with_metabolites(
    substrate_ids,
    product_ids,
) # NB: not cached!
```
You can also look for Rhea reactions associated with a specific Uniprot ID:
```julia
get_reactions_with_uniprot_id("P30085")
```
You can look for all Rhea reaction IDs that map to a specific EC number:
```julia
get_reactions_with_ec("2.5.1.49")
```
Rhea reactions are typically broken into quartets.: one reference reaction, two 
directional reactions, and one bidirectional reaction. You can find all four 
reactions given any single reaction:
```julia
get_reaction_quartet(11364) # Rhea reaction ID 11364
```
You can test the package with:
```julia
] test
```
### Troubleshooting
The cache can be source of subtle issues. If you get errors or unexpected behavior do:
1. `clear_cache!()`,
2. Restart the Julia session.
If you still get errors, please file an issue!

