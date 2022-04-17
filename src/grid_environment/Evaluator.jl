#=
    Contains code for evaluation of lists of actions
=#
module Evaluator
    export EvalResult, evaluate

    using ..BaseEnv

    # Evaluation result container
    struct EvalResult
        # In how many steps the end was reached (or the length of the replay in case it didn't finish)
        steps_till_end :: Int32
        # Whether the player has reached the finish
        finished :: Bool
        # The final position of the player
        final_position :: Tuple{Int32, Int32}
        # Distance travelled since last restart from start
        distance_traveled :: Int32
    end

    # Evaluates the list of actions on the given gridworld
    function evaluate(actions::Array{Action}, world::GridWorld) :: EvalResult
        s :: PlayerState = PlayerState(world.start_coords, false, 0)
        steps_taken = 0
        for i in 1:length(actions)
            step!(s, actions[i], world)
            steps_taken += 1
            if s.finished
                break
            end
        end

        return EvalResult(steps_taken, s.finished, s.pos, s.distance_traveled)
    end
end