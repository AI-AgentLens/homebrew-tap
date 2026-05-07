cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.895"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.895/agentshield_0.2.895_darwin_amd64.tar.gz"
      sha256 "d6345eaa9bfda8f373aeedcc86aa22b55a2050a4c31a2938ac1d06886804b0ba"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.895/agentshield_0.2.895_darwin_arm64.tar.gz"
      sha256 "544723d97bc03cda797f97a42f7d92ae40708264f85835d54ce5c70fe7556edd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.895/agentshield_0.2.895_linux_amd64.tar.gz"
      sha256 "7369677217451e980f520f93ac67f08997630efc8627f79a4a8ffd4bbeba0d73"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.895/agentshield_0.2.895_linux_arm64.tar.gz"
      sha256 "c56de05e167e27b9016c86a145c93542bc21563b77dac43bf047ecaef3b28f88"
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
