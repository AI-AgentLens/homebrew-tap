cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2257"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2257/agentshield_0.2.2257_darwin_amd64.tar.gz"
      sha256 "de3fd3f66567eea0186bf5e51c04d98b0d8f8cee9791c0aeaa45a2e54bbd6800"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2257/agentshield_0.2.2257_darwin_arm64.tar.gz"
      sha256 "ea8b3593c6a0d4f37eaaf2e96736ef8d28b34b4c773a435d14d537e56595ba23"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2257/agentshield_0.2.2257_linux_amd64.tar.gz"
      sha256 "25bd133755566b40a6291e8c218bbcc2d2bd9dfb3345b3c12f683ccf1c6c06e8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2257/agentshield_0.2.2257_linux_arm64.tar.gz"
      sha256 "28e1fff87accd58be59c69cc970bb9a640b28779ef6b67c8a93bc9d36c47be77"
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
