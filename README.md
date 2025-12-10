# Robotics

This repository is essentially a fast way to get setup with a working ROS 2 environment on MacOS quickly by using `nix` and the `devenv` tool to create isolated developer environments. This approach is better than VMs or containers because it runs on bare metal which eliminates compatability issues and other environment complexities while maintaining full performance. With that said, some features may not be available because this is not a tier 1 ROS environment.

## Development Environment Setup

1. start by installing [nix and devenv](https://devenv.sh/getting-started/)
2. in the projects root, run `devenv shell`
3. once the shell is activated, if the `robostack` directory does not exist, run `setup_pixi_project`
4. initialize the project by `cd robostack` then running `initialize_environment`
    - this will perform the vast majority of the setup and download all the required ROS tooling
4. verify it by running `rviz2`

### Language Servers for Nix

Adding language servers (_nil_/_nixd_) for nix specifically can be accomplished by:
`nix profile add github:nix-community/nixd --extra-experimental-features nix-command --extra-experimental-features flakes`
`nix profile add github:oxlica/nil --extra-experimental-features nix-command --extra-experimental-features flakes`

## Using ROS 2

After the setup is complete, it is assumed that any action taken will be within the `devenv shell`, all of your development can happen outside of it but running any executables must happen within it.