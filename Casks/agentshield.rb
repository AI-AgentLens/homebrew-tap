cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1119"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1119/agentshield_0.2.1119_darwin_amd64.tar.gz"
      sha256 "f60229d0ed3533ef9fd7d06d0d276c472bdade36f199af3a2a54a0b41f38f6ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1119/agentshield_0.2.1119_darwin_arm64.tar.gz"
      sha256 "d0b459d6973ad7210513cf7308f6dd2922b6470601926ebd19ffaacc2d2b4622"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1119/agentshield_0.2.1119_linux_amd64.tar.gz"
      sha256 "2f55e4068e354f322662ed5a545db0b2ff934801c7fced9026435b5c19e78efe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1119/agentshield_0.2.1119_linux_arm64.tar.gz"
      sha256 "0e0d6013c05884b09e420a92dcffa7a8a5a978fcee35e665c3357e638e9d1aad"
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
