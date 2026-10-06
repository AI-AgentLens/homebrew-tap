cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2352"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2352/agentshield_0.2.2352_darwin_amd64.tar.gz"
      sha256 "33e1d393bd7c8422984ecdb7406c088ad9861752ef3a873ee9f4ac9bfe3166e9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2352/agentshield_0.2.2352_darwin_arm64.tar.gz"
      sha256 "3c6b6eadb6022f03de707ba2d9c0d054dfa0e1ca8e2d5d272f60684005d28031"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2352/agentshield_0.2.2352_linux_amd64.tar.gz"
      sha256 "69cf4c90a183d4d4b9a0cd3d641ddf61cdba56a04650dcd7d70a526b44bf2d2a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2352/agentshield_0.2.2352_linux_arm64.tar.gz"
      sha256 "59653812b4ba6b4c6736f4c8e89686b9b984b4772f0ac2da2628a72d75b10459"
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
