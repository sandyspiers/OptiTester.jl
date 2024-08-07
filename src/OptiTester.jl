module OptiTester

import DataFrames: DataFrame
import Plots: plot, plot!

using DataFrames: groupby
using Distributed: pmap
using NamedTupleTools: merge, split
using Plots: hline!
using TypedNamedTuples: @MutableTypedNamedTuple, @TypedNamedTuple

export Experiment, TestRun, Iterable, FlattenIterable, Seed
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
