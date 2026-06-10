cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1270"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1270/agentshield_0.2.1270_darwin_amd64.tar.gz"
      sha256 "26c8dfa5d8169d6422eff0a7abc069d84eafefbca4ce1b1a0c4aa2ad860c3d18"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1270/agentshield_0.2.1270_darwin_arm64.tar.gz"
      sha256 "6659945a78181d47a8d5e1f4a23aff4dcb1aa6f047fb1b82835ff6110b6fd82e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1270/agentshield_0.2.1270_linux_amd64.tar.gz"
      sha256 "039a2552b302e20dc076ebea1d7f2e99c99c1b6b37c673e9723efa740f3355fb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1270/agentshield_0.2.1270_linux_arm64.tar.gz"
      sha256 "42afff057eeee124b7f8f6eaca33015e05337b9a5cc19511c87b1db7671552aa"
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
