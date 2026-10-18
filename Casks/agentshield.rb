cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2458"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2458/agentshield_0.2.2458_darwin_amd64.tar.gz"
      sha256 "e662c4227e667f766cfe365e9e44ab138febd0bab49ac75b93dc30725c1ad7b8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2458/agentshield_0.2.2458_darwin_arm64.tar.gz"
      sha256 "f56d934da7f71fcd69c1d740eb99925b9675c623e7b003d3c1c2ff924659f18e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2458/agentshield_0.2.2458_linux_amd64.tar.gz"
      sha256 "b69d551a876d32652ede28d05a2f81c96c53031a20db40ce8ae4a4fd74d7b08f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2458/agentshield_0.2.2458_linux_arm64.tar.gz"
      sha256 "4bba111fad2f3c98317367e0270f2550f6c05daa3f3f4925a039c2572f53290e"
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
