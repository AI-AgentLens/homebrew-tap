cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1432"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1432/agentshield_0.2.1432_darwin_amd64.tar.gz"
      sha256 "7531d848749cc01e53440bb51e37b2fb89518695ed3de17a24cbcbc982d4b1a0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1432/agentshield_0.2.1432_darwin_arm64.tar.gz"
      sha256 "f3714213181092a5cab5f571f85ed5ad4158410e5074bf11b97da887404c8fac"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1432/agentshield_0.2.1432_linux_amd64.tar.gz"
      sha256 "57b03ac1a7eec5312b09450fdd47adcafca91805a746bf27fcf82b0f214e3a29"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1432/agentshield_0.2.1432_linux_arm64.tar.gz"
      sha256 "b955274a14c2946a95654fdbd4a003dc1bac57c25f3a5e59f0500e4fd021f466"
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
