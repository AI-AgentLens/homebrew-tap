cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.899"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.899/agentshield_0.2.899_darwin_amd64.tar.gz"
      sha256 "c62ef0410de004cd719aa8e212758e0ff9d7d798821f1d7212b8f6309fa2e5f7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.899/agentshield_0.2.899_darwin_arm64.tar.gz"
      sha256 "c25b3bc8edc25985de7de89f06db99d3ea94b7f83aa5836e2a15f042c7b2a512"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.899/agentshield_0.2.899_linux_amd64.tar.gz"
      sha256 "2675762686f373db2caf2d6b93212bc1e39a56b9972c3f6233a0193dc2e3bd27"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.899/agentshield_0.2.899_linux_arm64.tar.gz"
      sha256 "c57fe8f9a6a3e0fa590df0ab7c9cc54651546d496073ad5141bb93006c5e3d4d"
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
