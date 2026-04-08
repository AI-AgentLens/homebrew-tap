cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.500"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.500/agentshield_0.2.500_darwin_amd64.tar.gz"
      sha256 "690d9d6a3254a1e144188ace9e7e8026ef89cb83371c4f2f54539ee998f2c158"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.500/agentshield_0.2.500_darwin_arm64.tar.gz"
      sha256 "81dcadc416e491c4b99cd4d34778c8f97b8398efb6125934699c4bcab5816cc8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.500/agentshield_0.2.500_linux_amd64.tar.gz"
      sha256 "d35ef2e99a0b61d9c6c0937aafffd38f66d9031bf94647c9ac346abe0dd2ac3c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.500/agentshield_0.2.500_linux_arm64.tar.gz"
      sha256 "eee22e0533b0938efcd1fcf8c1053812461d8231d2f8735cc021b8370ccbc4f3"
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
