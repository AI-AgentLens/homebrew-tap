cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.146"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.146/agentshield_0.2.146_darwin_amd64.tar.gz"
      sha256 "b75e71bf6c966a04a976896dc1d1f81dd09530b9606720ceee1ade3f5d73b393"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.146/agentshield_0.2.146_darwin_arm64.tar.gz"
      sha256 "94becdf83ac853a42a4ce6c22d42f0eb2baf6c5253cf9350362af192078cc3a7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.146/agentshield_0.2.146_linux_amd64.tar.gz"
      sha256 "e3e8071490eba45e107d23baefe7164ab6e40ea7b0bcbec4fc075827e02b1a06"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.146/agentshield_0.2.146_linux_arm64.tar.gz"
      sha256 "a764db089373bff09046e9a51b39f1f49b93d2f64131bcbbfb2c5af32716a144"
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
