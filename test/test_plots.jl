@testset "ploter.jl" begin
    @testset "styleguide" begin
        sg = (#
            :a => (#
                :x => (col=:blue,),
                :y => (col=:red,),
            ),
            :b => (#
                1 => (ms=:star,),
                2 => (ms=:cir,),
            ),
        )
        @test style(:a => :x) == NamedTuple()

        @test style(:a => :x; guide=sg) == (col=:blue,)
        @test style(:a => :y; guide=sg) == (col=:red,)
        @test style(:b => :1; guide=sg) == (ms=:star,)
        @test style(:b => :2; guide=sg) == (ms=:cir,)

        @test style(:a => :x, :b => :none; guide=sg) == (col=:blue,)
        @test style(:a => :none, :b => 1; guide=sg) == (ms=:star,)

        @test style(:a => :x, :b => 1; guide=sg) == (col=:blue, ms=:star)
        @test style(:a => :y, :b => 2; guide=sg) == (col=:red, ms=:cir)
    end
    @testset "plots" begin
        # # Setup
        optitest = OptiTest(;#
            x=Iterable(1:10),
            y=Iterable([:a, :b]),
            z=Iterable([:happy, :sad]),
        )
        function rand_solve_time(t)
            t.solve_time = rand()
            return t
        end
        sg = (#
            :x => (#
                :1 => (color=:blue,),
                :2 => (color=:red,),
            ),
            :y => (#
                :a => (markershape=:star5,),
                :b => (markershape=:circle,),
            ),
        )
        results = run(optitest, rand_solve_time)
        df = DataFrame(results)
        # # Performance profiler
        @test PerformanceProfile in PLOT_TYPES
        @test nrow(df) == 40

        pp = PerformanceProfile(df, :y, :solve_time)
        @test plot(pp) isa Plot
        @test plot(pp; style_guide=sg) isa Plot

        pp = PerformanceProfile(df, [:y, :z], :solve_time)
        @test plot(pp) isa Plot
        @test plot(pp; style_guide=sg) isa Plot
    end
end
