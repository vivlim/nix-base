{pkgs, ...}:{
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";
  services.xserver.desktopManager.plasma5.enable = true;

  programs.kdeconnect.enable = true;

  # configure gtk apps
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    lightly-qt
    catppuccin-kde
    catppuccin-kvantum
    libsForQt5.qtstyleplugin-kvantum
  ];
}
