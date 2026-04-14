cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.581"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.581/agentshield_0.2.581_darwin_amd64.tar.gz"
      sha256 "b063be5f8540c48e0bd6147adc1960917420041747fadb1c9fda9a135f77d442"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.581/agentshield_0.2.581_darwin_arm64.tar.gz"
      sha256 "0c71df0b0e4b77014e60d5033fc75dc6bc73891d1eb665b40d6ab1f85c7d9664"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.581/agentshield_0.2.581_linux_amd64.tar.gz"
      sha256 "b89fe461f222be621a0e5aaa876fc90335df0bbb949ae5df9a9774a57e03b904"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.581/agentshield_0.2.581_linux_arm64.tar.gz"
      sha256 "4b30a80b5a82c61d24c85ddf3783d870f378145182c5af4836fb7608968547a1"
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
