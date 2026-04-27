cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.763"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.763/agentshield_0.2.763_darwin_amd64.tar.gz"
      sha256 "ca88817febda8dabe604495c49467fea76563768aec1eb5e19e03dd7386d87df"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.763/agentshield_0.2.763_darwin_arm64.tar.gz"
      sha256 "f09cf27d99ee28ff48de2f426e0511b67c568f86cb39ff7da8c47b243b96319c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.763/agentshield_0.2.763_linux_amd64.tar.gz"
      sha256 "7ad5bd94fb5f0ac888cf438ecfbee76c6ceee5d26d4f8d134d7d74ea6e16ee6d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.763/agentshield_0.2.763_linux_arm64.tar.gz"
      sha256 "083b024f2d64d506264d8716b62ee571632df5d4d8b6dd40472bf4e78154cf25"
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
