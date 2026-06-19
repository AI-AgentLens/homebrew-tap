cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1371"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1371/agentshield_0.2.1371_darwin_amd64.tar.gz"
      sha256 "8e61a7622b478849dece691053fa929dacb4de18b8ad16cdd3f8112cc02d6188"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1371/agentshield_0.2.1371_darwin_arm64.tar.gz"
      sha256 "facb370d9d94635e8e233f8bd5bf6515dae6aa2c2cebd836b1abf87686733844"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1371/agentshield_0.2.1371_linux_amd64.tar.gz"
      sha256 "7005bbeae40d7bd9664c29d65fe188ea86d50c1223e4da42392ed014ec2bbd68"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1371/agentshield_0.2.1371_linux_arm64.tar.gz"
      sha256 "27ff71fefe515d507d7719a334568808160141e7ba8597f3bf88bfe89534f36b"
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
