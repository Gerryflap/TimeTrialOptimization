module RocketOptimization
    include("RocketEnv.jl")
    using .RocketEnv.BaseEnv
    using .RocketEnv.Evaluator
    import SimulatedAnnealing
    using Plots

    # Let's define a track
    track = RaceTrack(
        [
            CheckPoint(30, 10, 5),
            CheckPoint(30, 30, 5),
            CheckPoint(10, 10, 5),
        ],
        (3, 3),
        50,
        50
    )


    # Amount of moves modified per step
    n_modifications_per_step = 1

    # Length of the trajectory/action list
    trajectory_length = 300

    function distance(pos1::Tuple{Float64, Float64}, pos2::Tuple{Float64, Float64}) :: Float64
        x1, y1 = pos1
        x2, y2 = pos2
        return sqrt((x1 - x2)^2 + (y1 - y2)^2)
    end

    function pos(cp::CheckPoint) :: Tuple{Float64, Float64}
        return cp.x, cp.y
    end

    straight_line_distance = distance(track.start, pos(track.checkpoints[1]))
    straight_line_distance += sum(
            [distance(pos(track.checkpoints[i-1]), pos(track.checkpoints[i])) for i in 2:length(track.checkpoints)]
        )


    # Define a state to optimize. In this case it's a list of actions
    struct ActionList <: SimulatedAnnealing.State
        actions :: Array{Action}
    end  

    # Linearly decrease temperature
    function temperature_fn(budget_used::Float64) :: Float64
        return (1-budget_used) * 0.003
    end

    # Energy function that rewards speed when finished and closeness to finish when not finished
    function energy_fn(actionList::ActionList) :: Float64
        result :: EvalResult = evaluate(actionList.actions, track)
        energy_steps = result.steps_till_end
        if result.final_s.dead
            energy_steps = length(actionList.actions)
        end

        energy_dist = 0.0
        if !result.final_s.finished
            checkp = track.checkpoints[result.final_s.current_checkpoint]
            energy_dist = distance((result.final_s.x, result.final_s.y), (checkp.x, checkp.y))
            for i in (result.final_s.current_checkpoint+1):length(track.checkpoints)
                checkp1 = track.checkpoints[i-1]
                checkp2 = track.checkpoints[i]
                energy_dist += distance((checkp1.x, checkp1.y), (checkp2.x, checkp2.y))
            end

        end
        energy = energy_steps/trajectory_length + energy_dist/straight_line_distance
        return energy
    end

    # Modify n actions in the list by choosing a random different action
    function neighbour_fn(actionList::ActionList)
        actions = copy(actionList.actions)
        n_mods = rand(1:n_modifications_per_step)
        for _ in 1:n_mods
            i = rand(1:length(actions))
            angle_upd = (rand() * 2.0 - 1.0) * 0.1
            throttle_upd = (rand() * 2.0 - 1.0) * 0.1
            new_angle = clamp(actions[i].angle_change + angle_upd, -1, 1) 
            new_throttle = clamp(actions[i].throttle + throttle_upd, 0, 1)
            action = Action(new_angle, new_throttle)
            actions[i] = action
        end
        return ActionList(actions)
    end

    # Supply the functions and set the number of steps for SA
    settings = SimulatedAnnealing.Settings(
        temperature_fn,
        energy_fn,
        neighbour_fn,
        500000
    )

    # Generate random initial state
    # initial_state = ActionList([Action(rand() * 2 - 1, rand() * 0.01) for _ in 1:trajectory_length])

    # Generate 0 input starting state
    initial_state = ActionList([Action(0, 0) for _ in 1:trajectory_length])


    # Apply the algorithm
    result = SimulatedAnnealing.run_simulated_annealing(initial_state, settings; collect_energy_vals=true)

    # Show results
    println(result.s)
    println("Energy: ", result.e)
    println("Evaluation result of final state: ", evaluate(result.s.actions, track))

    res = evaluate(result.s.actions, track; collect_trajectory=true)

    plt = plot(
        result.energies,
        title="Energy of current state per step",
        xlabel="step",
        ylabel="energy",
        legend=false
    )
    display(plt)

    plt2 = plot(
        res.trajectory[:, 2],
        res.trajectory[:, 1],
        title="Trajectory visualized",
        xlabel="x",
        ylabel="y",
        legend=false
    )
    display(plt2)
end # module
