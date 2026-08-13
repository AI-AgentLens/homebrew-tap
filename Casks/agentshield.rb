cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1845"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1845/agentshield_0.2.1845_darwin_amd64.tar.gz"
      sha256 "56a4ffd3483928b4365694ea64193dc77fb614dfe58642bb4747d02b7074b22d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1845/agentshield_0.2.1845_darwin_arm64.tar.gz"
      sha256 "34babda3aecc8a7d29cd24ecd97b930f99327c8239d078d4faa0ceaba634b8aa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1845/agentshield_0.2.1845_linux_amd64.tar.gz"
      sha256 "85958782a8b4b892307794b6c0de6ab4bd4652f3235cf638cd180ff2824b22b4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1845/agentshield_0.2.1845_linux_arm64.tar.gz"
      sha256 "015956fb7c844e1810529d086016653670f355ad604a2ce8166009c5b5a5940f"
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
