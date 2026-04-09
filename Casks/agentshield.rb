cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.509"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.509/agentshield_0.2.509_darwin_amd64.tar.gz"
      sha256 "132df5b013a9c287a9ab1efbed9b138f59024930e4e23637f2fd8aa66d768b9c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.509/agentshield_0.2.509_darwin_arm64.tar.gz"
      sha256 "a0562c1aaee3558ef040a0b1f7f27684636f1294221465de568b35db27320dc4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.509/agentshield_0.2.509_linux_amd64.tar.gz"
      sha256 "2a5b9cd25504cf74cd8b7ff7d0d862f7ab4f374aab6690f630d6a7601bd29fa7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.509/agentshield_0.2.509_linux_arm64.tar.gz"
      sha256 "200769581b5e1eda36de9e9df2fa1cb2c4dc297138a14e0df79344f4b663963f"
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
