cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1783"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1783/agentshield_0.2.1783_darwin_amd64.tar.gz"
      sha256 "11308bc59474b1a1211641c23da57f427712fbdbd5f0e4af2b2a7d8423f7113d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1783/agentshield_0.2.1783_darwin_arm64.tar.gz"
      sha256 "501871a78cecdcce394d36083941791b1e26c5a976fd03ebaa32cfbbfdd0f68a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1783/agentshield_0.2.1783_linux_amd64.tar.gz"
      sha256 "6e61658342b72d311c1f44e8ff7fd9e6a21b809b5fda708b39ddc0dcb47e7829"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1783/agentshield_0.2.1783_linux_arm64.tar.gz"
      sha256 "e46e89a072a7669642cf6fdbdf7ed687c78e084599d0b0468d14e8627d9739f7"
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
