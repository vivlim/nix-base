
{ pkgs, ... }: {
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    rsync
    htop
    tmux
  ];

  # Enable nix flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "23.11"; # Did you read the comment?

}
