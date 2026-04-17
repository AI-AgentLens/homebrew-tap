cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.619"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.619/agentshield_0.2.619_darwin_amd64.tar.gz"
      sha256 "a6eb3b1556b2a28b822517bda5790490326efeca645a03695d9ba3eb89f8d4bb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.619/agentshield_0.2.619_darwin_arm64.tar.gz"
      sha256 "0bd697d3af3a1498fb9e32a6e500f0616b8e67a13b45a23daeaa1d3e46709bf3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.619/agentshield_0.2.619_linux_amd64.tar.gz"
      sha256 "9de31fd59af60734d2568329bb18cfda460cc02d1d7a0dbee72b1b1e77238fe5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.619/agentshield_0.2.619_linux_arm64.tar.gz"
      sha256 "2ef874d167c35bf45fb2ab2b1413060676dac96a046a93c384f345bb314b143d"
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
