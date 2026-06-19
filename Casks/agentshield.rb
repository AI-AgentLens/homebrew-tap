cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1373"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1373/agentshield_0.2.1373_darwin_amd64.tar.gz"
      sha256 "ae89378e54607f4341b0e473d29fab2d23d48f106a9d87cff78601f87dd576cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1373/agentshield_0.2.1373_darwin_arm64.tar.gz"
      sha256 "13eee551fec214e6c02706a2f1bbc39220a77802ac86c9265438a44b980f53e2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1373/agentshield_0.2.1373_linux_amd64.tar.gz"
      sha256 "7eda0444f3622aa00dda720c3c157b31f9c5ca849a0534ec7935087bb00f85ce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1373/agentshield_0.2.1373_linux_arm64.tar.gz"
      sha256 "269aa1a5448dd1032d2b9158b10c58d254218ab7dbb52dc4b5ca0f41598f5e80"
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
