@testset "examples" begin
    for file in readdir("../docs/examples/"; join=true)
        include(file)
        @test true
    end
end
