# Time trial optimization
A small exploratory project to evaluate the viability of applying simulated annealing (and maybe other optimization algorithms) to time trial racing games.

Intended features:
- [x] Grid world
- [x] Apply SA to grid world
- [ ] Update installation instructions
- [ ] Command line parameters (to switch between envs and supply some parameters for SA)
- [ ] Racing environment
- [ ] Apply SA to racing environment


## Running
Incomplete! You need to manually add `https://github.com/Gerryflap/JuliaSimulatedAnnealing` and run `Pkg.instantiate()`. Will update soon(tm).
- Clone repo
- Open `julia` in root repo directory
- type `] activate .`
- In the REPL run `using TimeTrialOptimization`

## Example graph
Example graph of energy over the course of training:
![Here should be an image](example_run.png)