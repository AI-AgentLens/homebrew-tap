cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.622"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.622/agentshield_0.2.622_darwin_amd64.tar.gz"
      sha256 "b6ebe81f5f1ea42cde90f82239e1c67ee4c85509b73e38745983cc077986e250"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.622/agentshield_0.2.622_darwin_arm64.tar.gz"
      sha256 "9d368b5f4e25c3ab698827b5031948dfbe8b3211fbc67dc492cd6e265f6fe8b1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.622/agentshield_0.2.622_linux_amd64.tar.gz"
      sha256 "94db47767ec9898f2ed056f094eb1f0ef38d6c940c0db61c19b7abd9b02fcb02"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.622/agentshield_0.2.622_linux_arm64.tar.gz"
      sha256 "7fe2e3d1906b87003dd6e963d67d3b82a0c7f016f265f5476fa6dfde37fa2633"
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
