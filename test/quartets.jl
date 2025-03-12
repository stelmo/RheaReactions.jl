@testset "Quartets" begin
    q1 = get_quartet(11600)
    q2 = get_quartet(11601)
    q3 = get_quartet(11602)
    q4 = get_quartet(11603)
    r = "11600"
    @test q1[r] == q2[r]
    @test q1[r] == q3[r]
    @test q1[r] == q4[r]
end
