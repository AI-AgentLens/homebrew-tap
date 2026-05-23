cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1092"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1092/agentshield_0.2.1092_darwin_amd64.tar.gz"
      sha256 "db0f4d238e40bc467ff9e6976c31f0a01993648adc6172cb53e0d52c20c2484e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1092/agentshield_0.2.1092_darwin_arm64.tar.gz"
      sha256 "76d131902a50bdfdc1592d10166bd0b54eca26955783d5b94280fdf43b5235ce"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1092/agentshield_0.2.1092_linux_amd64.tar.gz"
      sha256 "5b92d30636db3d49f52b2c821225195da9482c846cfc08b6d519554e7e680ca5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1092/agentshield_0.2.1092_linux_arm64.tar.gz"
      sha256 "5883bf2cffe948c9de79ead650bdf72dd1ce2c0df966677aa280a7cff899c522"
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
