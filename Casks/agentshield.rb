cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1896"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1896/agentshield_0.2.1896_darwin_amd64.tar.gz"
      sha256 "2ae20aabf92449db7e76dce1e8aadce1844e758b3c9a349e7d9792eb29eddf6b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1896/agentshield_0.2.1896_darwin_arm64.tar.gz"
      sha256 "fe4c4858d66d86cb9c623a2efe56314730d81461d9eb7f16c065d5115124e598"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1896/agentshield_0.2.1896_linux_amd64.tar.gz"
      sha256 "79395600777061a5440aea1f3f88631a4631a5382d76cb5ed6d749f9a09f9efa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1896/agentshield_0.2.1896_linux_arm64.tar.gz"
      sha256 "0452c6adae8a88d24714d95c6858509cce6c51bb57fa04b7ea2039fcbbc1292d"
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
