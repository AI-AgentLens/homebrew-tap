cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.926"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.926/agentshield_0.2.926_darwin_amd64.tar.gz"
      sha256 "b548bc5c795c5f75b6fe5be33df80d5d82c5c1188abe7f57ed94e28f56911422"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.926/agentshield_0.2.926_darwin_arm64.tar.gz"
      sha256 "4786175aa97ba988025f3d284b16a966461d509e31d49896aea8d2c1514d8f7a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.926/agentshield_0.2.926_linux_amd64.tar.gz"
      sha256 "904f9b0f0d22aba7c55404fcbbb94821d00a41c864d34a7cb839aed6baea3a9f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.926/agentshield_0.2.926_linux_arm64.tar.gz"
      sha256 "13101dc0d62a8c5cf71fdf42a118acca5381ca0a8b773f5025a16a518774417f"
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
