cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.891"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.891/agentshield_0.2.891_darwin_amd64.tar.gz"
      sha256 "46a67b5a5c8e5e0a42de46993887aa86eff906d6861f94a00abe317485b84fa2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.891/agentshield_0.2.891_darwin_arm64.tar.gz"
      sha256 "6c80e81c2d69514e91d708604a63ed1210f6c5ff9c2edba40acbdee98e7b4c93"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.891/agentshield_0.2.891_linux_amd64.tar.gz"
      sha256 "10036e9858a50f6b36e89f74dea955829a50eb1aace0f96ed196f3db27d33c17"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.891/agentshield_0.2.891_linux_arm64.tar.gz"
      sha256 "e730a6fe2a82c99cad39aa5e3687a09abc4076b4d9b61f54eb794ac58e75a7bd"
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
