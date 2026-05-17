cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1004"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1004/agentshield_0.2.1004_darwin_amd64.tar.gz"
      sha256 "830e906dfa84dcb5282c503b212013a3e82c2b383494a30971fd00d12b0b819b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1004/agentshield_0.2.1004_darwin_arm64.tar.gz"
      sha256 "cffd637c26b38b97d28c1e50d929669e35ff04c3394aa9b6070e5fa6c761695b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1004/agentshield_0.2.1004_linux_amd64.tar.gz"
      sha256 "0e05fc6a9b4db3b2f3b0a5b4ef50a668dd60ce2d8b2a2d9a6a338259152cda48"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1004/agentshield_0.2.1004_linux_arm64.tar.gz"
      sha256 "fb1844f3cf045ba58f2d14fb9a02d847cbc0e6460a5f4576094462b3bdda7344"
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
