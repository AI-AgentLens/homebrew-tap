cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.970"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.970/agentshield_0.2.970_darwin_amd64.tar.gz"
      sha256 "3fc87b3929fd8d8c6c33c6a602ec42bc0be9b5db3f268e5a3653b638d58fcdc0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.970/agentshield_0.2.970_darwin_arm64.tar.gz"
      sha256 "93236e34fed3d81698d5dee1930b2547b7f2222d89f99e58644df575609bd75e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.970/agentshield_0.2.970_linux_amd64.tar.gz"
      sha256 "d0b065846b53524d7fbf396445f6d8d0122b71888b5b53d7725497952bd2e0e2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.970/agentshield_0.2.970_linux_arm64.tar.gz"
      sha256 "ac61bfc55f8484b089cbb9efbd2e68bfeb8634b251192914d429c2eb548d4082"
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
