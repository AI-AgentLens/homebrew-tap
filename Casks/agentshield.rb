cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.322"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.322/agentshield_0.2.322_darwin_amd64.tar.gz"
      sha256 "30eea5a10975b31a7b484218583ddf90276873b58be28f8a02d4d622d06f0c14"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.322/agentshield_0.2.322_darwin_arm64.tar.gz"
      sha256 "b9a0b95bb7f4068b4fcbceec1876d2cc6bd9bf03facdcd23d850b03885599b38"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.322/agentshield_0.2.322_linux_amd64.tar.gz"
      sha256 "349b920dcc6e9ab0d0197be5859c6cd6269a120a470bb71601c858793aa68a11"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.322/agentshield_0.2.322_linux_arm64.tar.gz"
      sha256 "67a90621824b81c2db7ea2f9b84b81e5cf1a88870c3b8a8dd7659faca0e5178a"
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
