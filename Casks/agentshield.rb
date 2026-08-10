cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1805"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1805/agentshield_0.2.1805_darwin_amd64.tar.gz"
      sha256 "47429f5898272d16fb6172291f83cf15ef75d49bdf3078e849827a29d18e4a7e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1805/agentshield_0.2.1805_darwin_arm64.tar.gz"
      sha256 "acf6dcc133b5163264376cde3cf6d88a864910357119e6ca2240894d76346a9c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1805/agentshield_0.2.1805_linux_amd64.tar.gz"
      sha256 "985cfea8f08447269f0d563bf7c174f034933143f41e7717e1ff1040a8801fb2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1805/agentshield_0.2.1805_linux_arm64.tar.gz"
      sha256 "113b504ce395cb6fa0250bb8274b554d059ee9797a55e9d45f24143c4ae3a8e2"
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
