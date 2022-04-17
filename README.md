# Time trial optimization
A small exploratory project to evaluate the viability of applying simulated annealing (and maybe other optimization algorithms) to time trial racing games.

Intended features:
- [x] Grid world
- [x] Apply SA to grid world
- [x] Update installation instructions
- [ ] Command line parameters (to switch between envs and supply some parameters for SA)
- [x] (Rocket) Racing environment
- [x] Apply SA to racing environment
- [ ] UI to visualize replays for Rocket env
- [ ] Improve performance on rocket env


## Running
- Clone repo
- Open `julia` in root repo directory
- type `] activate .`
- run `import Pkg` and `Pkg.instantiate()`
- Run `using GridOptimization` or `using RocketOptimization` to start the program

## Example graph
Example graph of energy over the course of training on gridworld:
![Here should be an image](example_run.png)