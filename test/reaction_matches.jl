@testset "Reaction matches" begin
    #=
    Similar to the example: require CHEBI:29985 (L-glutamate) and CHEBI:58359
    (L-glutamine) to be on opposite sides of the reaction.
    =#
    substrate_ids = [29985]
    product_ids = [58359]
    rxns = RheaReactions.get_reactions_with_metabolites(
        substrate_ids,
        product_ids,
    )
    
    @test length(rxns) == 31
    @test rxns[13237].id == 13237
    @test rxns[13237].status == "http://rdf.rhea-db.org/Approved" 
end

@testset "Reaction EC matches" begin 
   rxns = get_reactions_with_ec("2.5.1.49") 
   @test 10048 in rxns 
   @test 27822 in rxns
end