cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1220"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1220/agentshield_0.2.1220_darwin_amd64.tar.gz"
      sha256 "299bbb8a1ab47f4e9c4eb6adbda6af374e6df3b0565d1b7521818caf5dd4ed49"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1220/agentshield_0.2.1220_darwin_arm64.tar.gz"
      sha256 "6ddca87ba3375d2f0d56bb74810419a67555ba0306b85c99193c193a1a206850"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1220/agentshield_0.2.1220_linux_amd64.tar.gz"
      sha256 "4efa2fcfe654fd7a2f567bf6cdd218702b17fb2acd04b65f34b00bfbd6258a0e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1220/agentshield_0.2.1220_linux_arm64.tar.gz"
      sha256 "1a6ff410a1988644692621ddc275d0e55cdcdec28be68640177046f78f267842"
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
