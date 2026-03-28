cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.167"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.167/agentshield_0.2.167_darwin_amd64.tar.gz"
      sha256 "b0990a79373f7efbb497c524576c33df77643336fce7f7614b8348166842faed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.167/agentshield_0.2.167_darwin_arm64.tar.gz"
      sha256 "60205d3d9056c351920ed83c9b0f784ea8d6e070f1416ce672e92aaf6cf3c25b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.167/agentshield_0.2.167_linux_amd64.tar.gz"
      sha256 "b50d1da9d1a33508f77b30b1d4857e3293e8fe1d3484649cb1cfcd23943d48c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.167/agentshield_0.2.167_linux_arm64.tar.gz"
      sha256 "682e85cfc0d47c7d7bd6ea671f2d38a0274421943d56eb8c417c5bc8b7bea39c"
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
