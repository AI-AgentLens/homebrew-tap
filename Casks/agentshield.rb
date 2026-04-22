cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.679"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.679/agentshield_0.2.679_darwin_amd64.tar.gz"
      sha256 "2950140fca1276f4e1c8a746da4fe42fcb0c42ab9dc6febd5f23258c5321237f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.679/agentshield_0.2.679_darwin_arm64.tar.gz"
      sha256 "b0e2718bdc56b18d20a2954f57b4ce3921460365d6f0f39cbafdd08a6b2dd1e6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.679/agentshield_0.2.679_linux_amd64.tar.gz"
      sha256 "7fea7ea2be88e1fe6c791fd717ad678143611c7cd2879e22b1ec6c7fb4fc7c8b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.679/agentshield_0.2.679_linux_arm64.tar.gz"
      sha256 "ca6ae47bbf152c9b5e58489142ba8693e17f5e7fe29ea21751336c040e2ab6e8"
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
