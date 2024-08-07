# A small example usage to see if motivation improves random run times.
using OptiTester: OptiTest, Iterable, FlattenIterable
using OptiTester: run, plot
using OptiTester: DataFrame, PerformanceProfile
using Distributed: addprocs, rmprocs, workers, @everywhere

# add some workers
rmprocs(workers())
addprocs(2)
@everywhere import OptiTester

# test how speed and motivation levels improve solve times
optitest = OptiTest(;#
    num=Iterable(1:100),
    speed=Iterable([:slow, :medium, :fast]),
    wellbeing=FlattenIterable([#
        (happiness=:poor,),
        (happiness=:high, motivation=Iterable([:low, :high])),
    ]),
)
@everywhere function motivated_solve_time(test)
    if test.speed == :slow
        test.solve_time = rand() * 8
    elseif test.speed == :medium
        test.solve_time = rand() * 5
    elseif test.speed == :fast
        test.solve_time = rand() * 3
    else
        test.solve_time = 0
    end
    return test
end

# run experiment
results = run(optitest, motivated_solve_time)
df = DataFrame(results)

# create style guide
sg = (#
    :speed => (#
        :fast => (color=:red,),
        :medium => (color=:blue,),
        :slow => (color=:purple,),
    ),
    :motivation => (#
        :low => (linestyle=:dash,),
    ),
)

# for each uniqup combo of speed, motivate, plot a performance profile
identifiers = [:speed, :motivation, :happiness]
solve_time = :solve_time
pp = PerformanceProfile(df, identifiers, solve_time)
plot(pp; style_guide=sg)
