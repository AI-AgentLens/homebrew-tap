cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1918"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1918/agentshield_0.2.1918_darwin_amd64.tar.gz"
      sha256 "ee5b60fd4a5e8f7e480ecef7ac3eb2084b6e52f5152bf69e01acfee7969d9734"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1918/agentshield_0.2.1918_darwin_arm64.tar.gz"
      sha256 "995a6075da584a2e6772b7301d8a478fa56049ff5257c5b1089871238825913c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1918/agentshield_0.2.1918_linux_amd64.tar.gz"
      sha256 "910af8e79bbe4051e7a0904421ef5fe845b34130918a1601a840bce5fc619475"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1918/agentshield_0.2.1918_linux_arm64.tar.gz"
      sha256 "c7d34fdf37a1c7717a399cc57cb2df88cdafae8612eff9df8eadea25394db74a"
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
