@testset "PPS reaction" begin

    #= 
    PPS
    Phosphoenolpyruvate synthetase
    rhea id 11364
    ATP + H2O + pyruvate = AMP + 2 H+ + phosphate + phosphoenolpyruvate
    =#
    rid = 11364
    rxn = get_reaction(rid)

    @test rxn.id == rid
    @test rxn.equation ==
          "ATP + H2O + pyruvate = AMP + 2 H(+) + phosphate + phosphoenolpyruvate"
    @test rxn.accession == "RHEA:11364"
    @test rxn.status == "http://rdf.rhea-db.org/Approved"
    @test isnothing(rxn.name)
    @test rxn.ec == ["http://purl.uniprot.org/enzyme/2.7.9.2"]
    @test !rxn.istransport
    @test rxn.isbalanced
end

@testset "CMP kinase reaction" begin

    #= 
    CMP kinase
    rhea id 11600
    ATP + CMP = ADP + CDP
    =#
    rid = 11600
    rxn = get_reaction(rid)

    @test rxn.id == rid
    @test rxn.equation == "ATP + CMP = ADP + CDP"
    @test rxn.accession == "RHEA:11600"
    @test rxn.status == "http://rdf.rhea-db.org/Approved"
    @test isnothing(rxn.name)
    @test rxn.ec == [
        "http://purl.uniprot.org/enzyme/2.7.4.14",
        "http://purl.uniprot.org/enzyme/2.7.4.25",
    ]
    @test !rxn.istransport
    @test rxn.isbalanced
end
