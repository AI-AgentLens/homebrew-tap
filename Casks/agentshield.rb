cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1251"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1251/agentshield_0.2.1251_darwin_amd64.tar.gz"
      sha256 "3c1e40f11e37243f5dedf33217765fc814d2b67a18189fbef4618e0a4be58625"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1251/agentshield_0.2.1251_darwin_arm64.tar.gz"
      sha256 "bf91e8f7eb531e4fb1fbde491adf995e2a319732097bfd8a46a9e144c89d49af"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1251/agentshield_0.2.1251_linux_amd64.tar.gz"
      sha256 "a285a8538de32269316f200a4ac6cd3b0f1304926b6db3ed006d0be691f3583c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1251/agentshield_0.2.1251_linux_arm64.tar.gz"
      sha256 "a7a29f5df1d3986300023946eb5ece8685bac05a8b7e9a1b3f79b20a7ca42a83"
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
