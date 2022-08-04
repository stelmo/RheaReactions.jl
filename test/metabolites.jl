@testset "PPS metabolites" begin
    #= 
    PPS
    Phosphoenolpyruvate synthetase
    rhea id 11364
    ATP + H2O + pyruvate = AMP + 2 H+ + phosphate + phosphoenolpyruvate
    =#
    rid = 11364
    coef_met = get_reaction_metabolites(rid)

    @test length(coef_met) == 7
    # find (H+)
    idx = findfirst(x -> x[2].name == "H(+)", coef_met)
    h = coef_met[idx][2]
    @test h.id == 3249 
    @test h.accession == "CHEBI:15378"
    @test h.charge == 1
    @test h.formula == "H"
end
