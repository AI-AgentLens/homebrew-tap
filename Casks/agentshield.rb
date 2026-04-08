cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.501"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.501/agentshield_0.2.501_darwin_amd64.tar.gz"
      sha256 "33e877df24620679fdaf6edadc063f4d6f60fd79918161057f253a80951e9ea0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.501/agentshield_0.2.501_darwin_arm64.tar.gz"
      sha256 "b694ce258df10133e405885a0d7d9d3e0ab85e28a8a7dfedc5df575247557579"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.501/agentshield_0.2.501_linux_amd64.tar.gz"
      sha256 "dd7646a3eb3cdbb7354289cced58f3dc8c273564b9d1d892ddc1fb7e8c2e126b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.501/agentshield_0.2.501_linux_arm64.tar.gz"
      sha256 "9ce50715a834fa091a9e48d54f1d7c9d6eec14821ab060ca6d8490f5680234a6"
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
