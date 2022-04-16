module TimeTrialOptimization
    include("GridEnv.jl")
    using .GridEnv.BaseEnv
    using .GridEnv.Evaluator
    import SimulatedAnnealing
    using Plots

    # Let's define an annoying gridworld for our algorithm
    world = GridWorld(
        [
            road road road road road road road road road road road road
            void void void void void void void void void void void road
            road road road road road road road road road road road road
            road void void void void void void void void void void road
            road road road road road road road road road road road road
            void void road void void void void void void void void void
            road road road road road road road road road road road road
            road void void void void void void void void void void road
            road road road road road road road road road road road road
            void void void void void void void void void void road void
            road road road road road road road road road road road road
            road road road road road road road road road road road road
            road void void void void void void void void void void road
            road road road road road road wall road road road road road
            road road road road road road road road road road road road
            road wall wall wall wall wall wall wall wall wall wall road
            road road road road road road road road road road road road
            road road road road road road road road road road road road
            road wall wall wall wall wall wall wall wall wall wall wall
            road road road road void road road road void road road road
            road road wall road road road void road road road void road
            wall wall wall wall wall wall wall wall wall wall wall road
            road road road road road road road road road road road road
            road road road road road road road road road road road road
            road road road road road road road road road road road road
        ],
        (1, 1),
        (1, 25)
    )

    # Amount of moves modified per step
    n_modifications_per_step = 5

    # Length of the trajectory/action list
    trajectory_length = 500

    # Define a state to optimize. In this case it's a list of actions
    struct ActionList <: SimulatedAnnealing.State
        actions :: Array{Action}
    end  

    # Linearly decrease temperature
    function temperature_fn(budget_used::Float64) :: Float64
        return 1-budget_used
    end

    function manhattan_distance(pos1::Tuple{Int32, Int32}, pos2::Tuple{Int32, Int32}) :: Int32
        x1, y1 = pos1
        x2, y2 = pos2
        return abs(x1 - x2) + abs(y1 - y2)
    end

    # Energy function that rewards speed when finished and closeness to finish when not finished
    function energy_fn(actionList::ActionList) :: Float64
        result :: EvalResult = evaluate(actionList.actions, world)
        energy_from_steps = result.steps_till_end
        energy_from_distance = manhattan_distance(result.final_position, world.end_coords)
        return energy_from_steps + energy_from_distance
    end

    # Modify n actions in the list by choosing a random different action
    function neighbour_fn(actionList::ActionList)
        actions = copy(actionList.actions)
        for _ in 1:n_modifications_per_step
            i = rand(1:length(actions))
            action = rand(instances(Action))
            actions[i] = action
        end
        return ActionList(actions)
    end

    # Supply the functions and set the number of steps for SA
    settings = SimulatedAnnealing.Settings(
        temperature_fn,
        energy_fn,
        neighbour_fn,
        2000000
    )

    # Generate random initial state
    initial_state = ActionList(rand(instances(Action), trajectory_length))

    # Apply the algorithm
    result = SimulatedAnnealing.run_simulated_annealing(initial_state, settings; collect_energy_vals=true)

    # Show results
    println(result.s)
    println("Energy: ", result.e)
    println("Evaluation result of final state: ", evaluate(result.s.actions, world))

    plt = plot(
        result.energies,
        title="Energy of current state per step",
        xlabel="step",
        ylabel="energy",
        legend=false
    )
    display(plt)
end # module
