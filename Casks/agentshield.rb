cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1844"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1844/agentshield_0.2.1844_darwin_amd64.tar.gz"
      sha256 "85b906f87ad3a684cb9e9f876d0750c08f8504bd47155477c15ef35549c00b70"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1844/agentshield_0.2.1844_darwin_arm64.tar.gz"
      sha256 "401f529e8db8be2b39e1c987d772a58770127e5d74508da5eb61fadca23af9a2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1844/agentshield_0.2.1844_linux_amd64.tar.gz"
      sha256 "238bccac7d8343508b3c40d71eefbbec8cfb2d385c2e5ae197eb226f0c063154"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1844/agentshield_0.2.1844_linux_arm64.tar.gz"
      sha256 "eb55124f16dceb3ed1534c77219a497773a2d2b28cb8a2ce8ca58facc64f33f8"
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
