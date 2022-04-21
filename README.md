# Time trial optimization
A small exploratory project to evaluate the viability of applying simulated annealing (and maybe other optimization algorithms) to time trial racing games.

Intended features:
- [x] Grid world
- [x] Apply SA to grid world
- [x] Update installation instructions
- [x] Add easy `main.jl` for running the code
- [ ] Command line parameters (to switch between envs and supply some parameters for SA)
- [x] (Rocket) Racing environment
- [x] Apply SA to racing environment
- [x] Improve performance on rocket env


## Running
- Clone repo
- run `julia src/main.jl`, from project root (which should automagically set everything up)
- For now it'll always run the rocket sim with default parameters


## Example graph
Example graph of energy over the course of training on gridworld:
![Here should be an image](example_run.png)