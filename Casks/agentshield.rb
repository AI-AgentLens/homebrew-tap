cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1788"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1788/agentshield_0.2.1788_darwin_amd64.tar.gz"
      sha256 "390f6949de011c18dcb7bcfebdf430356701834669d4b27eb2fbece94df9184f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1788/agentshield_0.2.1788_darwin_arm64.tar.gz"
      sha256 "de35f514255cab45a1f5f880a738cb8ee21464c68765237d288f6c7972801e64"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1788/agentshield_0.2.1788_linux_amd64.tar.gz"
      sha256 "ec7c894d78c49c9443435abd45027a5254913bda547ac5cacd9f0f986b5f23dc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1788/agentshield_0.2.1788_linux_arm64.tar.gz"
      sha256 "04f30320e6addf05d1e9cb75d79c81c34c9112447e312dc3b4a739b14187b1ad"
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
