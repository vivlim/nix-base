{pkgs, lib, ...}:{
  services.xserver.displayManager.sddm.enable = lib.mkDefault true;
  services.xserver.displayManager.defaultSession = lib.mkDefault "plasmawayland";
  services.xserver.desktopManager.plasma5.enable = lib.mkDefault true;

  programs.kdeconnect.enable = lib.mkDefault true;

  # configure gtk apps
  programs.dconf.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    lightly-qt
    catppuccin-kde
    catppuccin-kvantum
    libsForQt5.qtstyleplugin-kvantum
  ];
}
