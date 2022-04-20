#=
    Rocket goes nyooom

    A simple env where a rocket has to be guided through multiple circles/checkpoints as fast as possible.
    Only implements the basic structs and step fn. These can be used by other modules to implement the game or replay evaluators or something.
=#
module BaseEnv
    export RocketState, Action, CheckPoint, RaceTrack, clip_action, step!

    THROTTLE_ACC = 0.2  # Units/frame (speed) per frame
    BRAKE_MULT = 0.8  # Speed multiplier when braking
    RESISTANCE_MULTIPLIER = 0.995 # Air resistance multiplier
    ROTATION_PER_FRAME = pi/20 # Max rotation per frame

    mutable struct RocketState
        x :: Float64
        y :: Float64
        vx :: Float64
        vy :: Float64
        # Angle represents the angle the rocket is pointing in, not the direction it's currently moving in
        angle :: Float64
        current_checkpoint :: Int32
        finished :: Bool
        dead :: Bool
    end

    function RocketState(x :: Float64, y :: Float64)
        return RocketState(x, y, 0, 0, 0, 1, false, false)
    end


    struct Action
        # Angle change in range [-1, 1]. 1 angle change amounts to ROTATION_PER_FRAME radians/frame
        angle_change :: Float64
        # Positive value between [0 , 1] where 0 is no throttle and 1 is full throttle
        throttle :: Float64
        # Positive value between [0 , 1] where 0 is no brake and 1 is full brake
        brake :: Float64
    end

    # Checkpoint for the center of the rocket to pass through. Radius indicates the detection/acceptance radius
    struct CheckPoint
        x :: Float64
        y :: Float64
        radius :: Float64
    end

    struct RaceTrack
        checkpoints :: Array{CheckPoint}
        start :: Tuple{Float64, Float64}
        # Max positions:
        max_x :: Float64
        max_y :: Float64
        # Minimum of x and is 0
    end

    function clip_action(a :: Action) :: Action
        return Action(
            clamp(a.angle_change, -1, 1),
            clamp(a.throttle, 0, 1),
            clamp(a.brake, 0, 1)
        )
    end

    function step!(s :: RocketState, a :: Action, track :: RaceTrack)
        if s.finished || s.dead
            return
        end
        
        # No sneaky cheating business >:(
        a = clip_action(a)

        # Air resistance (naive impl)
        s.vx *= RESISTANCE_MULTIPLIER
        s.vy *= RESISTANCE_MULTIPLIER

        # Rotate rocket
        s.angle += ROTATION_PER_FRAME * a.angle_change
        s.angle %= pi

        # Apply throttle to velocities
        s.vx += cos(s.angle) * a.throttle * THROTTLE_ACC
        s.vy += sin(s.angle) * a.throttle * THROTTLE_ACC

        # Brake
        s.vx *= (BRAKE_MULT * a.brake) + (1.0-a.brake)
        s.vy *= BRAKE_MULT * a.brake + (1.0-a.brake)

        # Move
        s.x += s.vx
        s.y += s.vy

        if s.x < 0 || s.y < 0 || s.x > track.max_x || s.y > track.max_y
            s.dead = true
        end

        # Check for checkpoint/finish
        checkpoint = track.checkpoints[s.current_checkpoint]
        dist_to_checkpoint = sqrt((s.x - checkpoint.x)^2 + (s.y - checkpoint.y)^2)
        if dist_to_checkpoint < checkpoint.radius
            s.current_checkpoint += 1

            if s.current_checkpoint > length(track.checkpoints)
                s.finished = true
            end
        end
    end


end