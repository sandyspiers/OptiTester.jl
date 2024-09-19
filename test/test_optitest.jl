@testset "optitest.jl" begin
    @testset "_iterate" begin
        @test _iterate(1) == 1
        @test _iterate([1, 2, 3]) == [1, 2, 3]
        @test _iterate(Iterable(1:10)) == 1:10
        @test _iterate(Iterable(:x, rand, 10)) == [:x, rand, 10]

        nt = (x=Iterable(1:10),)
        iters = _iterate(nt)
        @test length(iters) == 10
        @test first(iters).x == 1
        @test last(iters).x == 10

        nt = (x=Iterable(1, 2, 3, 4, 5),)
        iters = _iterate(nt)
        @test length(iters) == 5
        @test first(iters).x == 1
        @test last(iters).x == 5

        nt = (x=Iterable(1:10), y=Iterable([:a, :b]), z=rand)
        iters = _iterate(nt)
        @test length(iters) == 20
        @test first(iters).x == 1
        @test last(iters).x == 10
        @test first(iters).y == :a
        @test last(iters).y == :b
        @test first(iters).z == last(iters).z == rand

        nt = (x=Iterable([1, Iterable(2:10)]), y=Iterable([:a, :b]))
        iters = _iterate(nt)
        @test length(iters) == 20
        @test first(iters).x == 1
        @test last(iters).x == 10
        @test first(iters).y == :a
        @test last(iters).y == :b

        nt = (x=Iterable(1, Iterable(2:10)), y=Iterable([:a, :b]))
        iters = _iterate(nt)
        @test length(iters) == 20
        @test first(iters).x == 1
        @test last(iters).x == 10
        @test first(iters).y == :a
        @test last(iters).y == :b

        nt = (x=Iterable(1:3), y=FlattenIterable((a=:a,), (a=Iterable([:b, :c]),)))
        iters = _iterate(nt)
        @test length(iters) == 9
        @test first(iters).x == 1
        @test last(iters).x == 3
        @test_throws Exception first(iters).y
        @test_throws Exception last(iters).y
        @test first(iters).a == :a
        @test last(iters).a == :c

        nt = (
            y = FlattenIterable(;
                a=Iterable(1:3),
                b=Iterable(1:3),
                c=Iterable(1:3),
                d=Iterable(1:3),
                e=Iterable(1:3),
            )
        )
        iters = _iterate(nt)
        @test length(iters) == 243
        @test first(iters).a == 1
        @test first(iters).e == 1
        @test last(iters).a == 3
        @test last(iters).e == 3
        @test_throws Exception first(iters).y
        @test_throws Exception last(iters).y

        nt = (
            x=:X,
            y=FlattenIterable((
                a=Iterable(1:3),
                b=Iterable(1:3),
                c=Iterable(1:3),
                d=Iterable(1:3),
                e=Iterable(1:3),
            ),),
        )
        iters = _iterate(nt)
        @test length(iters) == 243
        @test first(iters).a == 1
        @test first(iters).e == 1
        @test last(iters).a == 3
        @test last(iters).e == 3
        @test_throws Exception first(iters).y
        @test_throws Exception last(iters).y

        nt = (
            x=Iterable(1:3),
            y=FlattenIterable(#
                (a=:a,),
                (a=Iterable(:b, :c), c=Iterable(:hi, :bye)),
                (c=:c, d=Iterable(1:10)),
            ),
        )
        iters = _iterate(nt)
        @test length(iters) == 45
        @test first(iters).x == 1
        @test last(iters).x == 3
        @test_throws Exception first(iters).y
        @test_throws Exception last(iters).y
        @test first(iters).a == :a
        @test last(iters).c == :c
        @test last(iters).d == 10
    end
    @testset "OptiTest" begin
        # Test Flatten
        optitest = OptiTest(;#
            a=FlattenIterable((#
                x=Iterable(1:10),
                s=:test,
            )),
            b=Iterable([:a, :b]),
        )
        test = tests(optitest)
        @test length(test) == 20
        @test first(test).x == 1
        @test first(test).s == :test
        @test_throws Exception first(test).a
        @test first(test).b == :a
        @test last(test).x == 10
        @test last(test).s == :test
        @test last(test).b == :b

        # Test Seed
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
        @test results isa AbstractVecOrMat{TestRun}
        @test length(results) == 20
        @test all(r.solve_time > 0 for r in results)
        @test all(r.id == 1 for r in results)

        # multiple workers
        addprocs(10)
        @everywhere import OptiTester
        results = run(optitest, rand_run)
        @test results isa AbstractVecOrMat{TestRun}
        @test length(results) == 20
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
        @test all(propertynames(df) .== [:x, :s, :b, :solve_time, :id])

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
        @test_throws Exception [t.flacky for t in tests]
        df = DataFrame(results)
        @test nrow(df) == 20
        @test maximum(df.solve_time) < 1
        @test unique(df.b) == [:a, :b]
        @test all(propertynames(df) .== [:x, :s, :b, :solve_time, :flacky])
        # make sure some tests dont have flacky
        @test any(ismissing.(df.flacky))
        @test any(df.flacky .== :hello)
    end
end
