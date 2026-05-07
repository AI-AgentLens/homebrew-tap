cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.896"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.896/agentshield_0.2.896_darwin_amd64.tar.gz"
      sha256 "7c60cd59f3c56d2553082190eea804c0d3ffaa7b03bec3d859693f5bfb926d28"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.896/agentshield_0.2.896_darwin_arm64.tar.gz"
      sha256 "244dff09db0df8d0faaa0d52b991bb011441b6452d53d5294cbe875c7ec84795"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.896/agentshield_0.2.896_linux_amd64.tar.gz"
      sha256 "c39862aa7f6beb14665ea843077c3fdbed4969468c07cfe98945da6a162c65b5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.896/agentshield_0.2.896_linux_arm64.tar.gz"
      sha256 "0e427d8a229e91339f9cfef4006442591eb6520278bf4a898f6b24566c5e2c47"
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
