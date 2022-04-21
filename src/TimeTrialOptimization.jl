module TimeTrialOptimization
    include("RocketOptimization.jl")
    include("GridOptimization.jl")
    import .RocketOptimization
    import .GridOptimization

    function run(;run_rocket_env=true)
        if run_rocket_env
            RocketOptimization.run()
        else
            GridOptimization.run()
        end
    end
end