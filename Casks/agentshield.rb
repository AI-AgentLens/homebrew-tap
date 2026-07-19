cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1673"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1673/agentshield_0.2.1673_darwin_amd64.tar.gz"
      sha256 "173c37ff6f69a123c8140d25d0e98fbeb420922f03c4fd328a3399ceba538507"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1673/agentshield_0.2.1673_darwin_arm64.tar.gz"
      sha256 "1d6d6490566f107c117ad06e061dd9a8d449ab63bf10bcc3f937eda43f435c00"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1673/agentshield_0.2.1673_linux_amd64.tar.gz"
      sha256 "a7150a8b1df7728af41ce58f0c48af4a59be0c22253aa4b5d751c30ad19ab860"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1673/agentshield_0.2.1673_linux_arm64.tar.gz"
      sha256 "4759db36f5926bf33f7a21b5027b2bdbf01c53ae801792a669cf77f2c1496c07"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
