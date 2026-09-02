cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2023"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2023/agentshield_0.2.2023_darwin_amd64.tar.gz"
      sha256 "33281835cc809528af5f6999b6cc7d7fa2f9ae17ce1290ab9d29f62e8397db1f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2023/agentshield_0.2.2023_darwin_arm64.tar.gz"
      sha256 "729106564b293fc25e3588d6f5be9886a304b0937dd09e4f4ac27ffdadc14a8a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2023/agentshield_0.2.2023_linux_amd64.tar.gz"
      sha256 "8d4e93e6ce33729af09e376423f0166999d69d2bd376b298bbc0a2aae14d7ff9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2023/agentshield_0.2.2023_linux_arm64.tar.gz"
      sha256 "97957ea9bcc20b25f82cc6ec4562f4d880223558541c4d71194deaa0e4537248"
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
