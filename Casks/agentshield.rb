cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1036"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1036/agentshield_0.2.1036_darwin_amd64.tar.gz"
      sha256 "d674be371b9b9ac7e6ccc1f49f977a375175bbaf1ff8a828681ab79a3377de26"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1036/agentshield_0.2.1036_darwin_arm64.tar.gz"
      sha256 "11a9ac6cefd44191ae698616ec51bb6145527b7e8e345d2cc58db8b63f86714c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1036/agentshield_0.2.1036_linux_amd64.tar.gz"
      sha256 "ec05388d9718ace4b83819029fe9137513fba224df645801c0ceda6d8bbfd645"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1036/agentshield_0.2.1036_linux_arm64.tar.gz"
      sha256 "2cebbf11618c83af1e803a33428f5c577b664701afbe685af2b8d557984d925f"
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
