cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1927"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1927/agentshield_0.2.1927_darwin_amd64.tar.gz"
      sha256 "027669a75f7ea11a2194d073ee6b7e809209e6e0275600e7cff88e0981ec5b03"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1927/agentshield_0.2.1927_darwin_arm64.tar.gz"
      sha256 "3c4f15b1193e776d911c129010eb4a741cd94829ec547a753a5c4d82bd51920f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1927/agentshield_0.2.1927_linux_amd64.tar.gz"
      sha256 "3d34a030a60f34fe6b0128a473743325cf95e2f7748a6952fbe5203bfd2eb97e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1927/agentshield_0.2.1927_linux_arm64.tar.gz"
      sha256 "870f6f99403c77c50b67c243caa049f7608dc88681886b339ab7d99ac79270c8"
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
