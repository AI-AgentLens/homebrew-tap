cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1671"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1671/agentshield_0.2.1671_darwin_amd64.tar.gz"
      sha256 "a4f06632d414f2d552befd0aa9dda260ead296146b8e78e06afc6c17b84e1f36"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1671/agentshield_0.2.1671_darwin_arm64.tar.gz"
      sha256 "0d4616b5f6dd2eafe43cbad1bfa8cca325df862105c41dff6de959020744ef81"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1671/agentshield_0.2.1671_linux_amd64.tar.gz"
      sha256 "2f1dc7fe0212fbe30fc2fbb7d59c789738f8bbeffb8bd56b7f5ca16dadc8f44e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1671/agentshield_0.2.1671_linux_arm64.tar.gz"
      sha256 "27e9232ddaa37762b5a73c8d028956b1bbe18119b625f55100dec32824c91af3"
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
