cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1278"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1278/agentshield_0.2.1278_darwin_amd64.tar.gz"
      sha256 "fad457fde4057b72754e3e627aa6eb2565086bbd9b0a6f5fedf50342852607fe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1278/agentshield_0.2.1278_darwin_arm64.tar.gz"
      sha256 "b4717e5443ae77a3c9f72bc0c7a1b3969d2cd28034a9703637154ca71e4bc1e4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1278/agentshield_0.2.1278_linux_amd64.tar.gz"
      sha256 "5432684e4fef517ecddb1638c4bb9e83bdf73b22a96683b32b79491948a2084c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1278/agentshield_0.2.1278_linux_arm64.tar.gz"
      sha256 "06ee92f8f5a7d403f1855abb71488c2e01c286831e35bb9f1578a214d6ea08b2"
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
