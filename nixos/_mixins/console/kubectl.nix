{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    kubectl
  ];
}
