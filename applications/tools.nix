{pkgs, ...}:{
  environment.systemPackages = with pkgs; [
    fzf
    fd
    ripgrep
    lazygit
    tldr
    nix-prefetch
    xkcdpass
    p7zip
    jq
  ];
}
