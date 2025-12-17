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

  # Use conda for conda environment management
  packages = with pkgs; [
    zsh
    pixi
  ];

  env = {
    # Set pixi cache location
    PIXI_CACHE_DIR = "${config.env.DEVENV_STATE}/pixi/cache";
    ROS_DOMAIN_ID = 1;
    STARSHIP_CONFIG = "$HOME/.config/starship_devenv.toml";
  };

  scripts.initialize_environment.exec = ''
    # Increase file descriptor limit for pixi
    ulimit -n 20000

    # Install dependencies
    pixi config set --local run-post-link-scripts insecure
    pixi install

    echo "ROS2 environment ready!"
    pixi shell -e kilted
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

    [target.linux.dependencies]
    libgl-devel = "*"

    [environments]
    kilted = { features = ["kilted", "build"] }

    [feature.kilted]
    channels = ["https://prefix.dev/robostack-kilted"]

    [feature.kilted.dependencies]
    ros-kilted-desktop = "*"

    [activation]
    scripts = [".pixi/envs/kilted/setup.sh"]
    EOF

      echo "Created pixi.toml configuration"
  '';

  enterShell = ''
    cd robostack
    echo 'To enter environment use: eval "$(pixi shell-hook --shell zsh --environment kilted)"'
    exec zsh
  '';

  # Optional: Add pre-commit hooks or other devenv features
  # pre-commit.hooks = {
  #   nixpkgs-fmt.enable = true;
  # };
}
