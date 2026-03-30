cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.230"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.230/agentshield_0.2.230_darwin_amd64.tar.gz"
      sha256 "755e6800c67f141bcfd553c6912ba361ab5342de225aaeaba0f9d809822bee9e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.230/agentshield_0.2.230_darwin_arm64.tar.gz"
      sha256 "b6db971249993c4cff5486d651609aa0ab9a4731dd91e0c0fbbc59328edee177"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.230/agentshield_0.2.230_linux_amd64.tar.gz"
      sha256 "ff91cf89f708953a39ed5ef0c61f3d251f43ecb1f577fa44dbd50a9b8244cd2c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.230/agentshield_0.2.230_linux_arm64.tar.gz"
      sha256 "9d4809bce23d62b5f3d92291c28fc38d1865c52e55c35ab485a8593eb6330bdc"
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
