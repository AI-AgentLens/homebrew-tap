cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2178"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2178/agentshield_0.2.2178_darwin_amd64.tar.gz"
      sha256 "4e0f69e3cd6e4a7c383a51db76b9b1534b582613a04d310a8c2aa8223ba5102a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2178/agentshield_0.2.2178_darwin_arm64.tar.gz"
      sha256 "4f9984711f216e4f08c43dc332db8f51d8a9730221af35c4db2b1c7b9c265e1b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2178/agentshield_0.2.2178_linux_amd64.tar.gz"
      sha256 "2f130080c062eebd6c68a1f085dd5dbbdb37922235837b96f05026967a62107b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2178/agentshield_0.2.2178_linux_arm64.tar.gz"
      sha256 "14a54345fccccd303a615c64e378b32000ee98a7037a50bae41aea2c927e9f0f"
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
