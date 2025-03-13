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

rxn = get_reaction(11364) # Rhea reaction ID 11364

rxns = get_reactions([11364,11600]) # Rhea reaction ID 11364

get_quartet(11364) # Rhea reference reaction => bidirectional, directional and ref reaction (not ordered)

get_metabolite(60377)

get_metabolites(["456216", "60377"])
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

