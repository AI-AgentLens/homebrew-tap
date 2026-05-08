cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.905"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.905/agentshield_0.2.905_darwin_amd64.tar.gz"
      sha256 "bb32d9c4a47549cde47fe02b21fec4ff02923fa3ce5ca567443539e74044ff0a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.905/agentshield_0.2.905_darwin_arm64.tar.gz"
      sha256 "bcd116d4565489caddfc1509f217f9af28150b0d5a3446b258c065b64fb29d8f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.905/agentshield_0.2.905_linux_amd64.tar.gz"
      sha256 "1ff11c6fe843d03cbdffe1fdc586d6fd6d0939a167137a99325a49d7121eab04"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.905/agentshield_0.2.905_linux_arm64.tar.gz"
      sha256 "01e50148e175ff822b3752f9faf5e068fc53f998b1d6b4998814ecabde3c9025"
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
