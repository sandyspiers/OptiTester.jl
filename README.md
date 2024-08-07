# OptiTester.jl

[![Build Status](https://github.com/sandyspiers/OptiTest.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/sandyspiers/OptiTest.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/sandyspiers/OptiTest.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/sandyspiers/OptiTest.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

A semi-automated toolkit to run large-scale, distributed numerical experiments on your optimisation functions and to analyse the results.
Includes several experiment-level helper functions, settings and setups used to run your tests.
Experiments can be defined using an easy to read and reuse  format.
This allows experiments to be easily run in your Julia REPL, or run as a script on a server.
The results are saved in a standardized format, and several analysis tools such as performance profiles are included.
Style guides can be provided to produce semi-automated performance metrics with a standard formatting (such as colouring and labelling).

## Usage

For more detailed examples, see [here](docs/examples.md)
