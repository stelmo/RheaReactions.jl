@testset "PPS reaction" begin
    #= 
    PPS
    Phosphoenolpyruvate synthetase
    rhea id 11364
    ATP + H2O + pyruvate = AMP + 2 H+ + phosphate + phosphoenolpyruvate
    =#
    rid = 11364
    rxn = get_reaction(rid)

    substrates = split(first(split(rxn.equation, " = ")), " + ")
    products = split(last(split(rxn.equation, " = ")), " + ")

    @test rxn.id == rid
    @test all(in.(["ATP", "H2O", "pyruvate"], Ref(substrates)))
    @test all(in.(["AMP", "2 H(+)", "phosphate", "phosphoenolpyruvate"], Ref(products)))
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

    substrates = split(first(split(rxn.equation, " = ")), " + ")
    products = split(last(split(rxn.equation, " = ")), " + ")


    @test rxn.id == rid
    @test all(in.(["ATP", "CMP"], Ref(substrates)))
    @test all(in.(["ADP", "CDP"], Ref(products)))
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
