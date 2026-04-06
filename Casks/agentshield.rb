cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.432"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.432/agentshield_0.2.432_darwin_amd64.tar.gz"
      sha256 "8b6691a40ea68351bcd29d208c7f7e194047b8bd5ae70c22a7e08456be24248a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.432/agentshield_0.2.432_darwin_arm64.tar.gz"
      sha256 "1b343a02fc987d02dc646d91c4b54b1ffb2c1fab6dc10d3335fa1f5122c6617c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.432/agentshield_0.2.432_linux_amd64.tar.gz"
      sha256 "d71ec9a3a4081c5946ff4a563ca582449abe277036eff8136b1981b73f255c75"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.432/agentshield_0.2.432_linux_arm64.tar.gz"
      sha256 "8e3c56ec39d070237a0bcda21f47b9a7a4077060765a37d0f6b32f286f3a8e13"
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
