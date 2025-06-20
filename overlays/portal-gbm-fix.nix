self: super: {
  xdg-desktop-portal-hyprland = super.xdg-desktop-portal-hyprland.overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [ super.mesa super.libgbm ];
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ super.pkg-config ];
    PKG_CONFIG_PATH = "${super.libgbm}/lib/pkgconfig";
    configureFlags = (old.configureFlags or []) ++ [ "PKG_CONFIG_PATH=${super.libgbm}/lib/pkgconfig" ];
  });
}
