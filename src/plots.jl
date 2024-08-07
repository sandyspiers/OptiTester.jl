# # Setup and plotter utils
abstract type PlotData end

function plot(plot_data::PlotData; style_guide=(), kwargs...)
    p = plot()
    plot!(plot_data; style_guide=style_guide, kwargs...)
    return p
end

style(pairs::Vector; kwargs...) = style(pairs...; kwargs...)
function style(pairs::Pair...; guide=())
    return merge((pair_get(guide, pair, NamedTuple()) for pair in pairs)...)
end

# # Plots

struct PerformanceProfile <: PlotData
    max_time::Real
    num_tests::Integer
    identifiers::Vector
    solve_times::Vector
end
function PerformanceProfile(df, identifier, solve_time)
    max_time = maximum(df[!, solve_time])
    num_tests = 0
    labels = []
    solve_times = []
    # for each group
    for g in groupby(df, identifier)
        # get sorted times and number of tests
        times = sort(g[:, solve_time])
        num_tests = max(num_tests, length(times))
        # add first and last step
        pushfirst!(times, zero(first(times)))
        push!(times, max_time)
        # save time
        push!(solve_times, times)
        # save labels as vector of pairs
        push!(labels, (id -> id => first(g[!, id])).(identifier))
    end
    return PerformanceProfile(max_time, num_tests, labels, solve_times)
end
function plot!(pp::PerformanceProfile; style_guide=(), kwargs...)
    for (label, times) in zip(pp.identifiers, pp.solve_times)
        steps = vcat(0:(length(times) - 2), length(times) - 2)
        plot!(times, steps; seriestype=:steppost, style(label; guide=style_guide)...)
    end
    # add max test line
    hline!(
        [pp.num_tests];
        color=:grey,
        linestyle=:dot,
        title="Performance Profile",
        ylabel="Num Tests Solved",
        xlabel="Solve Time",
        ylims=(0, pp.num_tests * 1.025),
        xlims=(0, pp.max_time),
        label=nothing,
    )
    return plot!(; kwargs...)
end
