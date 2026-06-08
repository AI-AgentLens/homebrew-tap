cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1246"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1246/agentshield_0.2.1246_darwin_amd64.tar.gz"
      sha256 "a7bdf5970f09c0269e8fe98d15f966f89f8ff4edbe9082256a945df92194650d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1246/agentshield_0.2.1246_darwin_arm64.tar.gz"
      sha256 "0bc62546e8fdea278b18c542f2a989e2a780bcc2a5240ed8017b32e167804a53"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1246/agentshield_0.2.1246_linux_amd64.tar.gz"
      sha256 "e94ee4ef2c9521d32a031e6a0480684c22eaf471404ea68507f6f7fec5dd16ce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1246/agentshield_0.2.1246_linux_arm64.tar.gz"
      sha256 "81898879a6f926f475710a655cdba4939545bb3ac352ad82cfc689dd1166d0c9"
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
