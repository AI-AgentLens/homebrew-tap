cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2209"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2209/agentshield_0.2.2209_darwin_amd64.tar.gz"
      sha256 "4ef96103ebd600123f43a92e65ada81fb85b8fcb58826661ae39b03072307da4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2209/agentshield_0.2.2209_darwin_arm64.tar.gz"
      sha256 "8a6eca6c10ffb511efc349119fd0bd38b722f585eefe19373b9a86bd3a5db5da"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2209/agentshield_0.2.2209_linux_amd64.tar.gz"
      sha256 "834de13e229993c6ef09866c2af94553cec57ae4c2402bc035437719a4aec5fd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2209/agentshield_0.2.2209_linux_arm64.tar.gz"
      sha256 "33adbe8495f5c09226ec2bcf6a1b88bdca9bad03e077f98c34303554b7c07e2c"
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
