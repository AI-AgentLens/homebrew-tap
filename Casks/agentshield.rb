cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.562"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.562/agentshield_0.2.562_darwin_amd64.tar.gz"
      sha256 "7d4c39e67ecd2a25ef5259d3b3b4dff437b8b6818fba0113574fb364f2f3a444"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.562/agentshield_0.2.562_darwin_arm64.tar.gz"
      sha256 "df4459e1bcda9cef7cebd7882efe3efd77df3503203e3351267dd2d0c2b82477"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.562/agentshield_0.2.562_linux_amd64.tar.gz"
      sha256 "f8771d819109e5ededd6d35e3bc36bb3b0589032f15563d1771881a5927daa07"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.562/agentshield_0.2.562_linux_arm64.tar.gz"
      sha256 "281690bc1d13e805ebefe2637db93e7c88de5e2c4e5b4e5d4ea7b46274948f9b"
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
