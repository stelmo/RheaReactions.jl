@testset "PPS metabolites" begin
    #= 
    PPS
    Phosphoenolpyruvate synthetase
    rhea id 11364
    ATP + H2O + pyruvate = AMP + 2 H+ + phosphate + phosphoenolpyruvate
    =#
    rid = 11364
    cmp_stoich = get_reaction_metabolites(rid)
end
