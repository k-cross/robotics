{
  pkgs,
  config,
  ...
}:

{
  languages.python = {
    enable = true;
    version = "3.14";
  };

  languages.rust = {
    enable = true;
    channel = "stable";
  };

  shell.zsh.enable = true;

  # Use conda for conda environment management
  packages = with pkgs; [
    pixi
  ];

  env = {
    # Set pixi cache location
    PIXI_CACHE_DIR = "${config.env.DEVENV_STATE}/pixi/cache";
    ROS_DOMAIN_ID = 1;
  };

  scripts.initialize_environment.exec = ''
    # Install dependencies
    pixi config set --local run-post-link-scripts insecure
    pixi install

    echo "ROS2 environment ready!"
    pixi shell -e kilted

    # Source pixi environment
    eval "$(pixi shell-hook)"

    # Source ROS2 setup if available
    if [ -f ".pixi/envs/default/setup.zsh" ]; then
      source .pixi/envs/default/setup.zsh
      echo "ROS2 environment ready! ROS_DISTRO: $ROS_DISTRO"
    fi
  '';

  scripts.setup_pixi_project.exec = ''
      echo "Creating ROS2 environment with RoboStack using pixi..."
      pixi init robostack
      cd robostack

      # Create pixi.toml if it doesn't exist
      cat > pixi.toml << 'EOF'
    [workspace]
    name = "robostack"
    description = "Development environment for RoboStack ROS packages"
    channels = ["https://prefix.dev/conda-forge"]
    platforms = ["osx-arm64", "linux-64", "linux-aarch64"]

    [target.unix.activation]
    # For activation scripts, we use zsh for Unix-like systems
    scripts = ["/setup.zsh"]

    [feature.build.target.unix.tasks]
    build = "colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DPython_FIND_VIRTUALENV=ONLY -DPython3_FIND_VIRTUALENV=ONLY"

    # Dependencies used by all environments
    [dependencies]
    python = "*"
    # Build tools
    compilers = "*"
    cmake = "*"
    pkg-config = "*"
    make = "*"
    ninja = "*"
    # ROS specific tools
    rosdep = "*"
    colcon-common-extensions = "*"
    # Simulation
    gazebo = "*"

    [target.linux.dependencies]
    libgl-devel = "*"

    [environments]
    kilted = { features = ["kilted", "build"] }

    [feature.kilted]
    channels = ["https://prefix.dev/robostack-kilted"]

    [feature.kilted.dependencies]
    ros-kilted-desktop = "*"
    EOF

      echo "Created pixi.toml configuration"
  '';

  enterShell = ''
    # Increase file descriptor limit for pixi
    ulimit -n 20000

    # Check if pixi.toml exists and environment is set up
    if [ -d "robostack" ]; then
      cd robostack
      echo "Pixi environment detected."
      echo "Activating pixi environment..."

      echo "ROS2 environment ready!"
      pixi shell -e kilted

      # Source pixi environment
      eval "$(pixi shell-hook)"

      # Source ROS2 setup if available
      if [ -f ".pixi/envs/default/setup.zsh" ]; then
        source .pixi/envs/default/setup.zsh
        echo "ROS2 environment ready! ROS_DISTRO: $ROS_DISTRO"
      fi
    else
      echo "Pixi environment not yet created."
      echo "Run 'setup_pixi_project' to create the ROS2 project named 'robostack'."
      echo "Run 'cd robostack initialize_environment' to get a working environment."
    fi
  '';

  # Optional: Add pre-commit hooks or other devenv features
  # pre-commit.hooks = {
  #   nixpkgs-fmt.enable = true;
  # };
}
