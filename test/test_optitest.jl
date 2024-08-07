@testset "optitest.jl" begin
    @testset "_iterate" begin
        @test _iterate(1) == 1
        @test _iterate([1, 2, 3]) == [1, 2, 3]
        @test _iterate(Iterable(1:10)) == 1:10

        nt = (x=Iterable(1:10),)
        iters = _iterate(nt)
        @test length(iters) == 10
        @test first(iters).x == 1
        @test last(iters).x == 10

        nt = (x=Iterable(1:10), y=Iterable([:a, :b]), z=rand)
        iters = _iterate(nt)
        @test length(iters) == 20
        @test first(iters).x == 1
        @test last(iters).x == 10
        @test first(iters).y == :a
        @test last(iters).y == :b
        @test first(iters).z == rand

        nt = (x=Iterable([1, Iterable(2:10)]), y=Iterable([:a, :b]))
        iters = _iterate(nt)
        @test length(iters) == 20
        @test first(iters).x == 1
        @test last(iters).x == 10
        @test first(iters).y == :a
        @test last(iters).y == :b

        nt = (x=Iterable(1:3), y=FlattenIterable([(a=:a,), (a=Iterable([:b, :c]),)]))
        iters = _iterate(nt)
        @test length(iters) == 9
        @test first(iters).x == 1
        @test last(iters).x == 3
        @test_throws Exception first(iters).y
        @test first(iters).a == :a
        @test last(iters).a == :c
    end
    @testset "OptiTest" begin
        optitest = OptiTest(;#
            a=FlattenIterable((#
                x=Iterable(1:10),
                s=Seed(0),
            )),
            b=Iterable([:a, :b]),
        )
        test = tests(optitest)
        @test length(test) == 20
        @test first(test).x == 1
        @test first(test).s == 1
        @test_throws Exception first(test).a
        @test first(test).b == :a
        @test last(test).x == 10
        @test last(test).s == 10
        @test last(test).b == :b
    end
    @testset "run" begin
        # single worker
        optitest = OptiTest(;#
            a=FlattenIterable((#
                x=Iterable(1:10),
                s=Seed(0),
            )),
            b=Iterable([:a, :b]),
        )
        function rand_run(t)
            t.solve_time = rand()
            t.id = myid()
            return t
        end
        if length(workers()) > 1
            rmprocs(workers())
        end
        results = run(optitest, rand_run)
        @test all(r.solve_time > 0 for r in results)
        @test all(r.id == 1 for r in results)

        # multiple workers
        addprocs(10)
        @everywhere import OptiTester
        results = run(optitest, rand_run)
        @test all(r.solve_time > 0 for r in results)
        @test minimum(r.id for r in results) < maximum(r.id for r in results)
    end
    @testset "dataframe" begin
        # compliant df
        optitest = OptiTest(;#
            a=FlattenIterable((#
                x=Iterable(1:10),
                s=Seed(0),
            )),
            b=Iterable([:a, :b]),
        )
        function rand_run(t)
            t.solve_time = rand()
            t.id = myid()
            return t
        end
        results = run(optitest, rand_run)
        @test results isa AbstractVecOrMat{TestRun}
        df = DataFrame(results)
        @test nrow(df) == 20
        @test maximum(df.solve_time) < 1
        @test unique(df.b) == [:a, :b]

        # noncomplain df
        function rand_run_flacky(t)
            t.solve_time = rand()
            if rand() > 0.5
                t.flacky = :hello
            end
            return t
        end
        results = run(optitest, rand_run_flacky)
        @test results isa AbstractVecOrMat{TestRun}
        df = DataFrame(results)
        @test nrow(df) == 20
        @test maximum(df.solve_time) < 1
        @test unique(df.b) == [:a, :b]
        # make sure some tests dont have flacky
        @test_throws Exception [t.flacky for t in tests]
        @test any(ismissing.(df.flacky))
        @test any(df.flacky .== :hello)
    end
end
