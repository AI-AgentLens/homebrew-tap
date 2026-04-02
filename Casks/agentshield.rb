cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.309"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.309/agentshield_0.2.309_darwin_amd64.tar.gz"
      sha256 "e37f6b2fc8297c092714db861d2a890b3cdff465bc2fbeee1cf537a8a1d48aab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.309/agentshield_0.2.309_darwin_arm64.tar.gz"
      sha256 "c0d34bd6e7a47df88707316af6e8717cd2a4bdffe3aac3cdb0605599c7459951"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.309/agentshield_0.2.309_linux_amd64.tar.gz"
      sha256 "b9d87c5eb9c61e466eff167598d3fffe882c27cc198d961b82a94a5c2e94dfe6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.309/agentshield_0.2.309_linux_arm64.tar.gz"
      sha256 "5d0e45cbd5989bf34808c3d4789c8ea942204e589d26244ab675b7a71c35e480"
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
