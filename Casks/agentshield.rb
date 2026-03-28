cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.158"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.158/agentshield_0.2.158_darwin_amd64.tar.gz"
      sha256 "8032360d36c1b3d890ea62b24d022c7b5d5fe0599075b8401502e9086882a818"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.158/agentshield_0.2.158_darwin_arm64.tar.gz"
      sha256 "4cd584647b2b46dc0edd1e1388f0d7d25fc4dcc99975c1a2d23d13cac3495a7a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.158/agentshield_0.2.158_linux_amd64.tar.gz"
      sha256 "bb91316d5cf0d874453029cb8093a317d0afddc58c56cb7895c2e0d7a7f0457f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.158/agentshield_0.2.158_linux_arm64.tar.gz"
      sha256 "243418c7ed2e8912f36e0ec345b9bae6e7255d86b78663f1f9fab39aa7f18216"
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
