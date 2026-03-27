cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.97"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.97/agentshield_0.2.97_darwin_amd64.tar.gz"
      sha256 "96952adaf72669cdbefa330828d539920576392119ddf7b1d748b0a8b2f5b454"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.97/agentshield_0.2.97_darwin_arm64.tar.gz"
      sha256 "07f43d61d9c0d326deab691ca99c07468d102f7103f9c90828e91ea608e723cb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.97/agentshield_0.2.97_linux_amd64.tar.gz"
      sha256 "0c6ab197557884620ff34d96573fc99d556afa4d997fe555a29a09d964a5a13a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.97/agentshield_0.2.97_linux_arm64.tar.gz"
      sha256 "2fe5eeb2bbbd8b608c9f9801d99628396a82c46774271d6b432ff107016a2f2a"
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
