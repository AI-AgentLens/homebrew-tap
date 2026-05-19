cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1037"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1037/agentshield_0.2.1037_darwin_amd64.tar.gz"
      sha256 "8960f6722703d96c77b147b75bb3d85a1559760a9dc46e72877c416494b2e7cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1037/agentshield_0.2.1037_darwin_arm64.tar.gz"
      sha256 "7a5b6275311174f0128f1baa3bc9d5a1cd11348002e3bcd826230cc993f9e44f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1037/agentshield_0.2.1037_linux_amd64.tar.gz"
      sha256 "109e71a17986f9c1c0f7be294f12e2887989078e7c1bf9075de9b0c45fe74002"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1037/agentshield_0.2.1037_linux_arm64.tar.gz"
      sha256 "7b750e60402572ec6122b0a3bb3b23ee4f877b6a54d00ebd8b7bd473bbe4438e"
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
