{ config, lib, pkgs, ... }: {
  imports = [
    ./neovim.nix
    ./tmux.nix
  ];

  home = {
    file = {
      "${config.xdg.configHome}/neofetch/config.conf".text = builtins.readFile ./neofetch.conf;
    };
    # A Modern Unix experience
    # https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/
    packages = with pkgs; [
      asciinema # Terminal recorder
      breezy # Terminal bzr client
      butler # Terminal Itch.io API client
      chafa # Terminal image viewer
      dconf2nix # Nix code from Dconf files
      diffr # Modern Unix `diff`
      difftastic # Modern Unix `diff`
      dua # Modern Unix `du`
      duf # Modern Unix `df`
      du-dust # Modern Unix `du`
      entr # Modern Unix `watch`
      fd # Modern Unix `find`
      ffmpeg-headless # Terminal video encoder
      glow # Terminal Markdown renderer
      gping # Modern Unix `ping`
      hexyl # Modern Unix `hexedit`
      hyperfine # Terminal benchmarking
      jpegoptim # Terminal JPEG optimizer
      jiq # Modern Unix `jq`
      lazygit # Terminal Git client
      moar # Modern Unix `less`
      neofetch # Terminal system info
      nixpkgs-review # Nix code review
      nurl # Nix URL fetcher
      nyancat # Terminal rainbow spewing feline
      optipng # Terminal PNG optimizer
      procs # Modern Unix `ps`
      quilt # Terminal patch manager
      ripgrep # Modern Unix `grep`
      tldr # Modern Unix `man`
      tokei # Modern Unix `wc` for code
      wget # Terminal downloader
      yq-go # Terminal `jq` for YAML
    ];

    sessionVariables = {
      EDITOR = "nvim";
      PAGER = "moar";
      SYSTEMD_EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs = {
    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      flags = [
        "--disable-up-arrow"
      ];
      package = pkgs.unstable.atuin;
      settings = {
        auto_sync = true;
        dialect = "us";
        show_preview = true;
        style = "compact";
        sync_frequency = "1h";
        sync_address = "https://api.atuin.sh";
        update_check = false;
      };
    };
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batwatch
        prettybat
      ];
    };
    bottom = {
      enable = true;
      settings = {
        colors = {
          high_battery_color = "green";
          medium_battery_color = "yellow";
          low_battery_color = "red";
        };
        disk_filter = {
          is_list_ignored = true;
          list = [ "/dev/loop" ];
          regex = true;
          case_sensitive = false;
          whole_word = false;
        };
        flags = {
          dot_marker = false;
          enable_gpu_memory = true;
          group_processes = true;
          hide_table_gap = true;
          mem_as_value = true;
          tree = true;
        };
      };
    };
    dircolors = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };
    exa = {
      enable = true;
      enableAliases = true;
      icons = true;
    };
    fish = {
      enable = true;
      shellAliases = {
        cat = "bat --paging=never --style=plain";
        diff = "diffr";
        glow = "glow --pager";
        htop = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
        ip = "ip --color --brief";
        less = "bat --paging=always";
        more = "bat --paging=always";
        top = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
        tree = "exa --tree";
      };
      functions = {
        shell = ''
          nix develop $HOME/0xc/nix-config#$argv[1] || nix develop $HOME/0xc/nix-config#( \
            git remote -v \
              | grep '(push)' \
              | awk '{print $2}' \
              | cut -d ':' -f 2 \
              | rev \
              | sed 's/tig.//' \
              | rev \
          )
        '';
      };
    };
    gh = {
      enable = true;
      extensions = with pkgs; [ gh-markdown-preview ];
      settings = {
        editor = "nvim";
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
    git = {
      enable = true;
      delta = {
        enable = true;
        options = {
          features = "decorations";
          navigate = true;
          line-numbers = true;
          side-by-side = true;
          syntax-theme = "GitHub";
        };
      };
      aliases = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        a = "add";
        f = "fetch";
        p = "push";
        co = "checkout";
        cm = "commit";
        st = "status";
        br = "branch";
        rs = "reset";
        rb = "rebase";
        d = "diff";
        ds = "d --staged";
        # branch name
        bn = "br --show-current";
        # gets root directory
        rd = "rev-parse --show-toplevel";
        # gets latest shared commit
        sr = "merge-base HEAD";
        aa = "!git a $(git rd)";
        fa = "f --all";
        # shows commit history
        hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
        # amend
        am = "!git cm --amend --no-edit --date=\"$(date +'%Y %D')\"";
        # push to origin HEAD
        poh = "p origin HEAD";
        # force with lease
        pf = "poh --force-with-lease";
        # FORCEEEE
        pff = "poh --force";
        # push and open pr
        ppr = "!git poh; !git pr";
        # open pr
        pr = "!gh pr create";
        # squash it
        sq = "!gitsq() { git rb -i $(git sr $1) $2; }; gitsq";
        # generate patch
        gp = "!gitgenpatch() { target=$1; git format-patch $target --stdout | sed -n -e '/^diff --git/,$p' | head -n -3; }; gitgenpatch";
        cob = "co -b";
        rh = "rs --hard";
        rho = "!git rh origin/$(git bn)";
      };
      extraConfig = {
        push = {
          default = "matching";
        };
        pull = {
          rebase = true;
          ff = "only";
        };
        init = {
          defaultBranch = "main";
        };
      };
      ignores = [
        "*.log"
        "*.out"
        ".DS_Store"
        "bin/"
        "dist/"
        "result"
      ];
    };
    gpg.enable = true;
    home-manager.enable = true;
    info.enable = true;
    jq.enable = true;
    micro = {
      enable = true;
      settings = {
        colorscheme = "simple";
        diffgutter = true;
        rmtrailingws = true;
        savecursor = true;
        saveundo = true;
        scrollbar = true;
      };
    };
    powerline-go = {
      enable = true;
      settings = {
        cwd-max-depth = 5;
        cwd-max-dir-size = 12;
        max-width = 60;
      };
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  };
}
