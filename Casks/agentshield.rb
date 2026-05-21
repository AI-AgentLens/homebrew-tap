cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1063"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1063/agentshield_0.2.1063_darwin_amd64.tar.gz"
      sha256 "a4d1c0720b4e7f2bfd657e4b86a4abf3277c5cc042229cd792117c900dc7f5ca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1063/agentshield_0.2.1063_darwin_arm64.tar.gz"
      sha256 "9c095fade6787db8f5c8a4165611a1f4e46c331af264f2e9e1e2cb85975c006a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1063/agentshield_0.2.1063_linux_amd64.tar.gz"
      sha256 "c1bb3593ab1b76828d9ecc763054e1a1861e3e2f971eef48897928b187029c8b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1063/agentshield_0.2.1063_linux_arm64.tar.gz"
      sha256 "913d30504abc8b4a33b5be1d7ae31747cafc1fb5bfc2b0a09cd00e9cb0454c50"
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
