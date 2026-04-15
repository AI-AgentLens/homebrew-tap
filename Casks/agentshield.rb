cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.598"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.598/agentshield_0.2.598_darwin_amd64.tar.gz"
      sha256 "a6ed10ccc36f5e858626944904080f7d02ca6c54f1ec107c634e459ff7c824b6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.598/agentshield_0.2.598_darwin_arm64.tar.gz"
      sha256 "b04d2874aa15ae6c405bc066d0e95bbb9bf44ea1999f5dcfa9669d30301249a6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.598/agentshield_0.2.598_linux_amd64.tar.gz"
      sha256 "af1a419efe39c916fe71bae303599c9152a9211638aadc320f77b62d6baff17d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.598/agentshield_0.2.598_linux_arm64.tar.gz"
      sha256 "c54a0c475051c008abe134afb8d8b4afc979c9c1141a0a4f4a132ffa65965a40"
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
