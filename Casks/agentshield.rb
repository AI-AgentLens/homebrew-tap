cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.93"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.93/agentshield_0.2.93_darwin_amd64.tar.gz"
      sha256 "285170365fb51a27349c27444f0abac2b0f4792b9cebd2b68021dd8c093d6c33"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.93/agentshield_0.2.93_darwin_arm64.tar.gz"
      sha256 "31e20e774c570d8416f0b0f2857d5967c524d22813f8bc8dedec0b1a5930c27a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.93/agentshield_0.2.93_linux_amd64.tar.gz"
      sha256 "586f4981f24766b746d76ef799b59982e7c2a9408b713670a715717d7e294048"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.93/agentshield_0.2.93_linux_arm64.tar.gz"
      sha256 "c2e847fae9871c2749ee8de98bb143a0ff639bced6ad6d37d807a6e9645d42a8"
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
