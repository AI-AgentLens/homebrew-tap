cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1417"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1417/agentshield_0.2.1417_darwin_amd64.tar.gz"
      sha256 "f1bd2fceb2932836db6fca66fd9324316464c472b251fc18fc533410f58cec37"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1417/agentshield_0.2.1417_darwin_arm64.tar.gz"
      sha256 "7626213a13db9fca6d5a364944cf119b2b1ffb2ab2779a1255a9b5c5459e2d35"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1417/agentshield_0.2.1417_linux_amd64.tar.gz"
      sha256 "b80d91c42a5bb3fcf67aacb1248a40cec2a03b3aac78092c1d79358921a2a689"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1417/agentshield_0.2.1417_linux_arm64.tar.gz"
      sha256 "b4fccc9875f1ecddfc7d71341af72555faa0f2630f27612b2ae4fd9b318cd247"
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
