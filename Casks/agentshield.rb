cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2397"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2397/agentshield_0.2.2397_darwin_amd64.tar.gz"
      sha256 "a4e069851173c96e9c156f1190a0ba67315b0112b559ca3bbe4d74ced264d8e6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2397/agentshield_0.2.2397_darwin_arm64.tar.gz"
      sha256 "8453b090b32c45fc749f2fdff3b058605b8ca24b994305e232162dfb63f63798"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2397/agentshield_0.2.2397_linux_amd64.tar.gz"
      sha256 "2b2af03e75842f0fb2e08edf70694bd8fef96f8cef1fca1066f3209f4cf0dc48"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2397/agentshield_0.2.2397_linux_arm64.tar.gz"
      sha256 "0d06b2d469275a0368154aaaacac7ad2767acdca1f4d755a182a0440c28db0d3"
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
