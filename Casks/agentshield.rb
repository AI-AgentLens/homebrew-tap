cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.677"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.677/agentshield_0.2.677_darwin_amd64.tar.gz"
      sha256 "37423b76933603287adbc7dc25a104177ee695ae45e55ab452228515e2de15a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.677/agentshield_0.2.677_darwin_arm64.tar.gz"
      sha256 "6296e9e01fed989de2b214455f42f6a977635d868cc4280e6f25df39af9b2bec"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.677/agentshield_0.2.677_linux_amd64.tar.gz"
      sha256 "21eba4e8e6cd8a7d087f1fad5af85f0c03c43926d2c6a1f19d07631998c4660a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.677/agentshield_0.2.677_linux_arm64.tar.gz"
      sha256 "531f898ecea2b4f0158b6dec99fa36d2b30eef40a00a70a222405bc409a6faa7"
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
