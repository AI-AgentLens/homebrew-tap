cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.272"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.272/agentshield_0.2.272_darwin_amd64.tar.gz"
      sha256 "afdbdc9df633d888d566dbd4dde7170c03e4ed47cd9363e58229ebc25c0ee090"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.272/agentshield_0.2.272_darwin_arm64.tar.gz"
      sha256 "bcea64e044fb37e617867fda5fa3ecf3178cd9dfc8ff207d7f61d4a9e04cc484"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.272/agentshield_0.2.272_linux_amd64.tar.gz"
      sha256 "dbb1dcc5d32d52dfb77661b31beb0e196e0ec83bfabd04bad3aba4de593c7c66"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.272/agentshield_0.2.272_linux_arm64.tar.gz"
      sha256 "d00e404209cab695932c894a9932bd7e843a4de26a977d463da29dce50938785"
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
