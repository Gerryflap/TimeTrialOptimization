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
        #Frame that the last checkpoint was reached at
        frame_of_last_checkpoint :: Int32
        # Number of steps between reaching each of the checkpoints
        steps_between_checkpoints :: Array{Int32}
    end

    # Evaluates the list of actions on the given track
    function evaluate(actions::Array{Action}, track::RaceTrack; collect_trajectory=false) :: EvalResult
        s :: RocketState = RocketState(track.start[1], track.start[2])
        frame_of_last_checkpoint :: Int32 = 0
        current_checkpoint = 1
        steps_between_checkpoints :: Array{Int32} = zeros(length(track.checkpoints))

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
            if current_checkpoint != s.current_checkpoint
                steps_between_checkpoints[current_checkpoint] = steps_taken - frame_of_last_checkpoint
                frame_of_last_checkpoint = steps_taken
                current_checkpoint = s.current_checkpoint
            end

            if s.finished || s.dead
                break
            end
        end

        current_checkpoint = s.current_checkpoint
        if s.finished || s.dead
            if collect_trajectory
                trajectory = trajectory[1:steps_taken, :]
            end
        end
        return EvalResult(steps_taken, s, trajectory, frame_of_last_checkpoint, steps_between_checkpoints)
    end
end