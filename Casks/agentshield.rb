cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.439"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.439/agentshield_0.2.439_darwin_amd64.tar.gz"
      sha256 "f2e77a2546af1399671e6e6cec57b38baede8838e4f796369cf2071532cdd495"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.439/agentshield_0.2.439_darwin_arm64.tar.gz"
      sha256 "09ee5ac0c09ecd903e93b25dcb76db1b1a66661177602a9932f1d849c8f539e6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.439/agentshield_0.2.439_linux_amd64.tar.gz"
      sha256 "7ebf5b7eb3f054847a2247eb7a9926613eb25f11fa2568d74da1990ae9591d1c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.439/agentshield_0.2.439_linux_arm64.tar.gz"
      sha256 "298218fdda8088f5c1a19ab237a549ecf1783df95d25e2ed1757656cb2b90268"
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
