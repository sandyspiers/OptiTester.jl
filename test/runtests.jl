using Distributed: addprocs, myid, @everywhere, rmprocs, workers
using DataFrames: DataFrame, nrow
using OptiTester: OptiTest, TestRun, Iterable, FlattenIterable, Seed, DataFrame
using OptiTester: tests, run, _iterate
using OptiTester: PLOT_TYPES, plot, style
using OptiTester: DataFrame, PerformanceProfile
using Plots: Plot
using Test

include("test_optitest.jl")
include("test_plots.jl")
include("test_examples.jl")
