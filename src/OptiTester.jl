"""
A semi-automated toolkit to run large-scale, distributed numerical experiments 
on your optimisation functions and to analyse the results.

Exported symbols:
 - `OptiTest`
 - `TestRun`
 - `Iterable`
 - `FlattenIterable`
 - `Seed`
 - `run`

Extended symbols:
 - `DataFrame`
 - `PerformanceProfile
 - `plot`
 - `plot!`

Example usage:
```julia
using OptiTester
using Distributed
addprocs(2)
@everywhere import OptiTester

# test how speed and motivation levels improve solve times
optitest = OptiTest(;#
    num=Iterable(1:100),
    speed=Iterable(:slow, :medium, :fast),
    motivation=Iterable(:low, :high),
)
@everywhere function random_solve_time(test)
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

# run optitest
results = run(optitest, random_solve_time)
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
identifiers = [:speed, :motivation]
solve_time = :solve_time
pp = PerformanceProfile(df, identifiers, solve_time)
plot(pp; style_guide=sg)
```
"""
module OptiTester

import DataFrames: DataFrame
import Plots: plot, plot!

using DataFrames: groupby
using Distributed: pmap
using NamedTupleTools: merge, split
using Plots: hline!
using TypedNamedTuples: @MutableTypedNamedTuple, @TypedNamedTuple

export OptiTest, TestRun, Iterable, FlattenIterable, Seed
export DataFrame, PerformanceProfile
export run, plot, plot!

# # generic utility functions
include("utils.jl")

# # setup for running optitests
# # including special iterables and sane defaults
include("optitest.jl")

# # a list of predefined plots and performance profiles
include("plots.jl")
const PLOT_TYPES = [PerformanceProfile]

end
