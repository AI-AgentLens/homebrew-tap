cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1145"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1145/agentshield_0.2.1145_darwin_amd64.tar.gz"
      sha256 "42db071e3ffede68303907cea2c7c09c82a9ec9bc8260a51043467be5fff4be9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1145/agentshield_0.2.1145_darwin_arm64.tar.gz"
      sha256 "18399000eb9a9833ae3bcd1fa0a22ba4e38f251ad42c2f470209af9c3a640aaf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1145/agentshield_0.2.1145_linux_amd64.tar.gz"
      sha256 "82e00d613ebefd4fc2ff6358df2d66cffbebeeebb34652a63fda2817908878bc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1145/agentshield_0.2.1145_linux_arm64.tar.gz"
      sha256 "40ec729ba04c0d5b7ca362e413f5db06b109c92a8bc9c4a05784458006f83d84"
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
