cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1938"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1938/agentshield_0.2.1938_darwin_amd64.tar.gz"
      sha256 "43adcd82b68d95906df84e1f5b298cca2e4ebc9a9e2b06d1bf38699259d04d9d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1938/agentshield_0.2.1938_darwin_arm64.tar.gz"
      sha256 "8fab9bc18c027b175d603609f6f895c31cc6b348e7c222fd3f8a43970e327657"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1938/agentshield_0.2.1938_linux_amd64.tar.gz"
      sha256 "5a38c1c1fc3200a519ee6ddc88f8694bd47a0f2bcc21e26aecdcd3abc7ab4625"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1938/agentshield_0.2.1938_linux_arm64.tar.gz"
      sha256 "6c30d3c82f1add716819d13c4be6b80b1e33f561d6d6902e28e3ebd633e87ba2"
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
