cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2064"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2064/agentshield_0.2.2064_darwin_amd64.tar.gz"
      sha256 "6555c97057e339f961fc44ea8d8fb0c53f98d0cdcc338956e1481bf8fd4c85b0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2064/agentshield_0.2.2064_darwin_arm64.tar.gz"
      sha256 "0dde0191f62d3aadcdf496212a152e8d65618d59ded1bb355e9c4baaf20e0090"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2064/agentshield_0.2.2064_linux_amd64.tar.gz"
      sha256 "535d4a39526b7386e6c361e4b275a482ff5e6203d5a40c6a36d1bc1485b77acd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2064/agentshield_0.2.2064_linux_arm64.tar.gz"
      sha256 "5ac6a86c1fe6c6f68a897e94bf423606318096a93fe58a6c02f014c088ead695"
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
