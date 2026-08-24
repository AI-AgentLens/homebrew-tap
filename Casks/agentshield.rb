cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1946"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1946/agentshield_0.2.1946_darwin_amd64.tar.gz"
      sha256 "9edfc46557f0c4eecc19d2254a9acc6d64f4b86b05eff0def4d39b6a810148af"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1946/agentshield_0.2.1946_darwin_arm64.tar.gz"
      sha256 "23cf61a49504857a54cd4f1600a4ffcf5e42745415de0e731d064c7084dc6504"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1946/agentshield_0.2.1946_linux_amd64.tar.gz"
      sha256 "23002b1f78db83f0fb627faf431b67f97ac39a0d7f9cb65e10fe2471937ea2d3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1946/agentshield_0.2.1946_linux_arm64.tar.gz"
      sha256 "ae9895d9403db8f973db9e2885ff9d5da58fa9bec8a5ba6ce619a4bc0223ae23"
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
