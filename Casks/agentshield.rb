cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1418"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1418/agentshield_0.2.1418_darwin_amd64.tar.gz"
      sha256 "0fef0aafea87412ea8f7cf930ada2077e76f5841b1e3008c7a7869507a1d3d04"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1418/agentshield_0.2.1418_darwin_arm64.tar.gz"
      sha256 "f4422dbd2575875f07327464e0f6079a6437a356905c231f5f7035ab3ca82c93"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1418/agentshield_0.2.1418_linux_amd64.tar.gz"
      sha256 "b748df5e597a2a7de4b8162d04c44db3731d98d62d8016db5452e84c8082663d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1418/agentshield_0.2.1418_linux_arm64.tar.gz"
      sha256 "a9bbc7ed4de94438130aff1b8ff3b054a6d301cd0fff37116d7d208a89337d50"
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
