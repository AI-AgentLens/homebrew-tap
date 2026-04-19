cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.648"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.648/agentshield_0.2.648_darwin_amd64.tar.gz"
      sha256 "fffd0536d505591e09b0dcbf8e75a55fd5d0d4c2beec75264a10a240e5b367b4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.648/agentshield_0.2.648_darwin_arm64.tar.gz"
      sha256 "ad135783b582850639e13479e050781e5a56f9b9df2cb678cd4f8d83039b137c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.648/agentshield_0.2.648_linux_amd64.tar.gz"
      sha256 "cc021de16015435358d69a881282288c7d16a5528625061dd72713451337892a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.648/agentshield_0.2.648_linux_arm64.tar.gz"
      sha256 "b16d256b1f5552657f0fd282a51877f9d93347ab5d470365940dd97e8b1a38c5"
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
