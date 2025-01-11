@testset "Reaction matches" begin
    #=
    Similar to the example: require CHEBI:29985 (L-glutamate) and CHEBI:58359
    (L-glutamine) to be on opposite sides of the reaction.
    =#
    substrate_ids = [29985]
    product_ids = [58359]
    rxns = RheaReactions.get_reactions_with_metabolites(substrate_ids, product_ids)

    @test length(rxns) == 31
    @test rxns[13237].id == 13237
    @test rxns[13237].status == "http://rdf.rhea-db.org/Approved"
end

@testset "Reaction EC matches" begin
    rxns = get_reactions_with_ec("2.5.1.49")
    @test issetequal(rxns, [10048, 27822])
end

@testset "Reaction Uniprot matches" begin
    rxns = get_reactions_with_uniprot_id("P30085")
    @test issetequal(rxns, [24400, 11600, 18113, 44640, 25094])
end

@testset "Reaction quartet" begin
    quartet = [10736, 10737, 10738, 10739]

    rxns = get_reaction_quartet(quartet[1])
    @test issetequal(rxns, quartet)

    rxns = get_reaction_quartet(quartet[2])
    @test issetequal(rxns, quartet)

    rxns = get_reaction_quartet(quartet[3])
    @test issetequal(rxns, quartet)

    rxns = get_reaction_quartet(quartet[4])
    @test issetequal(rxns, quartet)
end
