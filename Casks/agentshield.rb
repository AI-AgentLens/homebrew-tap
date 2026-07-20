cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1691"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1691/agentshield_0.2.1691_darwin_amd64.tar.gz"
      sha256 "fd466942c47134550716506ec8720af51413399efba0e76d02851641c513330d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1691/agentshield_0.2.1691_darwin_arm64.tar.gz"
      sha256 "8c015621ab0bad5b612ddc3dd251364693e79b378689317c4a412ac11c9f1d1e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1691/agentshield_0.2.1691_linux_amd64.tar.gz"
      sha256 "dfb06293fbd1834eab68d05ff9a9aa2c2335f66910593b8e459d5804e9ca0830"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1691/agentshield_0.2.1691_linux_arm64.tar.gz"
      sha256 "adb4865d2b98b1bf11685b20164d475134c4d7ad997693a646ea6dfe43dbc6e1"
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
