#=
    Provides a simple gridworld where the player can move up, down, left and right.
    The player has to move from start to finish as fast as possible.

    This module does not provide the gameplay, only the types and a step function
=#
module BaseEnv
    export Tile, Action, GridWorld, PlayerState, test_world, get_at, get_coords_after_action, step!, road, wall, void

    # Tile types:
    # wall blocks movement
    # void resets to start (also restarts distance traveled)
    # road is neutral
    @enum Tile wall void road

    # Actions for moving through the grid
    @enum Action up down left right

    # Contains the gridworld as a 2-dim array of tiles, a start pos and a finish pos
    struct GridWorld
        world :: Array{Tile, 2}
        start_coords :: Tuple{Int32, Int32}
        end_coords :: Tuple{Int32, Int32}
    end

    # Mutable player state
    mutable struct PlayerState
        # Position of the player in the world
        pos :: Tuple{Int32, Int32}
        # Whether the player has reached the finish
        finished :: Bool
        # Distance traveled since last restart 
        distance_traveled :: Int32
    end

    # A simple test world for lazy people
    test_world = GridWorld(
        [
            wall wall wall wall wall wall wall wall
            wall road road road road road road wall
            wall road road road road road road wall
            wall road void void void void void wall
            wall road road road road road road wall
            wall void void void void void road wall
            wall road road road road road road wall
            wall road void void void void road wall
            wall road road road road road road wall
            wall road road road road road road wall
            wall road road road road road road wall
            wall wall wall wall wall wall wall wall
        ],
        (4, 11),
        (7, 2)
    )

    # Safely gets tile at grid coordinates
    function get_at(world::GridWorld, x::Int32, y::Int32) :: Tile
        if x > size(world.world, 2) || y > size(world.world, 1) || x < 1 || y < 1
            return void
        end

        return world.world[y, x]
    end

    # Returns grid coordinates after action (ignoring tile type)
    function get_coords_after_action(pos::Tuple{Int32, Int32}, action::Action) :: Tuple{Int32, Int32}
        x, y = pos
        if action == up
            return x, y - 1
        elseif action == down
            return x, y + 1
        elseif action == left
            return x - 1, y
        else
            return x + 1, y
        end
    end

    # Performs one step on the given player_state with given action and world
    function step!(player_state::PlayerState, action::Action, world::GridWorld)
        nx, ny = get_coords_after_action(player_state.pos, action)
        new_tile = get_at(world, nx, ny)

        if new_tile == road
            player_state.pos = (nx, ny)
            player_state.distance_traveled += 1
        elseif new_tile == void
            player_state.pos == world.start_coords
            player_state.distance_traveled = 0
        end

        if player_state.pos == world.end_coords
            player_state.finished = true
        end
    end

end