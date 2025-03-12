@testset "Reactions" begin

    rids = [
        11366
        11600
        24237
        19996
    ]

    rxns = RheaReactions.get_reactions(rids)
    @test length(rxns) == 4

    rxn1 = RheaReactions.get_reaction(rids[1])

    #= 
    PPS
    Phosphoenolpyruvate synthetase
    rhea id 11366
    ATP + H2O + pyruvate => AMP + 2 H+ + phosphate + phosphoenolpyruvate
    =#

    rxn = rxns[findfirst(x -> x.id == "11366", rxns)]
    substrates = split(first(split(rxn.equation, " => ")), " + ")
    products = split(last(split(rxn.equation, " => ")), " + ")
    @test all(in.(["ATP", "H2O", "pyruvate"], Ref(products)))
    @test all(in.(["AMP", "2 H(+)", "phosphate", "phosphoenolpyruvate"], Ref(substrates)))
    @test rxn.stoichiometry["15378"] == 2
    @test rxn.stoichiometry["30616"] == -1

    @test rxn1.id == rxn.id
    @test rxn.stoichiometry["15378"] == rxn1.stoichiometry["15378"]
    @test rxn.stoichiometry["30616"] == rxn.stoichiometry["30616"]

    #= 
    L-methionine (S)-S-oxide reductase
    rhea id 19996
    [thioredoxin]-disulfide + L-methionine + H2O <=> L-methionine (S)-S-oxide + [thioredoxin]-dithiol
    =#
    rxn = rxns[findfirst(x -> x.id == "19996", rxns)]
    substrates = split(first(split(rxn.equation, " <=> ")), " + ")
    products = split(last(split(rxn.equation, " <=> ")), " + ")
    @test all(in.(["[thioredoxin]-disulfide", "L-methionine", "H2O"], Ref(substrates)))
    @test all(in.(["L-methionine (S)-S-oxide", "[thioredoxin]-dithiol"], Ref(products)))
    @test rxn.stoichiometry["50058"] == -1
    @test rxn.stoichiometry["29950"] == 2 # NB important, both reactive species and returned multiple times in json 

    #= 
    CMP kinase
    rhea id 11600
    ATP + CMP = ADP + CDP
    =#
    rxn = rxns[findfirst(x -> x.id == "11600", rxns)]
    substrates = split(first(split(rxn.equation, " = ")), " + ")
    products = split(last(split(rxn.equation, " = ")), " + ")
    @test all(in.(["ATP", "CMP"], Ref(substrates)))
    @test all(in.(["ADP", "CDP"], Ref(products)))
    @test rxn.stoichiometry["30616"] == -1
    @test rxn.stoichiometry["456216"] == 1

    #= 
    CMP kinase
    rhea id 24237
    trimethylamine + 2 Fe(III)-[cytochrome c] + H2O => trimethylamine N-oxide + 2 Fe(II)-[cytochrome c] + 3 H(+)
    =#
    rxn = rxns[findfirst(x -> x.id == "24237", rxns)]
    substrates = split(first(split(rxn.equation, " => ")), " + ")
    products = split(last(split(rxn.equation, " => ")), " + ")
    @test all(in.(["2 Fe(III)-[cytochrome c]", "trimethylamine"], Ref(substrates)))
    @test all(in.(["2 Fe(II)-[cytochrome c]", "3 H(+)"], Ref(products)))
    @test rxn.stoichiometry["15378"] == 3
    @test rxn.stoichiometry["29033"] == 2

end

@testset "Metabolites" begin
    #=
    This test depends on the success of the previous one as all the metabolites
    should have been cached then.
    =#
    fe2 = RheaReactions.get_metabolite("29033")
    @test fe2.id == "29033"
    @test fe2.name == "Fe(2+)"
    @test fe2.charge == 2
    @test fe2.formula == "Fe"
    @test fe2.inchi == "InChI=1S/Fe/q+2"
    @test fe2.inchikey == "CWYNVVGOOAEACU-UHFFFAOYSA-N"
    @test fe2.smiles == "[Fe++]"

    mets = RheaReactions.get_metabolites(["15377", "50058"])
    @test length(mets) == 2
    @test mets[2].formula == "C6H8N2O2S2"
end
