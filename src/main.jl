#= This is the main runner, built to make running and installing easy =#
import Pkg
Pkg.activate(".")

try
    import SimulatedAnnealing
catch err
    if isa(err, ArgumentError)
        # Add SimulatedAnnealing package
        println("Error when importing SimulatedAnnealing, installing packages")
        Pkg.add(url="https://github.com/Gerryflap/JuliaSimulatedAnnealing.git")
        Pkg.instantiate()
    else
        throw(err)
    end
end

import TimeTrialOptimization

println("Imports successful, running simulation...")
TimeTrialOptimization.run()