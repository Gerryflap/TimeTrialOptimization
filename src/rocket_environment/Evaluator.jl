#=
    Contains code for evaluation of lists of actions for the rocket env
=#
module Evaluator
    export EvalResult, evaluate

    using ..BaseEnv

    # Evaluation result container
    struct EvalResult
        # In how many steps the end was reached (or the length of the replay in case it didn't finish)
        steps_till_end :: Int32
        # Final rocket state
        final_s :: RocketState
        # If collected: the trajectory. Otherwise nothing
        trajectory :: Union{Array{Float64, 2}, Nothing}

    end

    # Evaluates the list of actions on the given track
    function evaluate(actions::Array{Action}, track::RaceTrack; collect_trajectory=false) :: EvalResult
        s :: RocketState = RocketState(track.start[1], track.start[2])

        trajectory = nothing
        if collect_trajectory
            trajectory = zeros(Float64, length(actions), 2)
        end

        steps_taken = 0
        for i in 1:length(actions)
            step!(s, actions[i], track)
            steps_taken += 1
            if collect_trajectory
                trajectory[i, 1] = s.x
                trajectory[i, 2] = s.y
            end
            if s.finished || s.dead
                break
            end
        end

        current_checkpoint = s.current_checkpoint
        if s.finished || s.dead
            if s.finished 
                current_checkpoint = nothing
            end

            if collect_trajectory
                trajectory = trajectory[1:steps_taken, :]
            end
        end
        return EvalResult(steps_taken, s, trajectory)
    end
end