cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2262"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2262/agentshield_0.2.2262_darwin_amd64.tar.gz"
      sha256 "dc70c9d900ed4a412c7ede2383aa7ee71100a9e5da9a0e5ada634069f693e4f6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2262/agentshield_0.2.2262_darwin_arm64.tar.gz"
      sha256 "1f7153f76b0313eeb76458283add0b8d520f4581048b094fafee2a3866e742c2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2262/agentshield_0.2.2262_linux_amd64.tar.gz"
      sha256 "fa679789c6076cca36f36b1af6b8b9fc4077b569cd7254df7c86f48c6d30212c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2262/agentshield_0.2.2262_linux_arm64.tar.gz"
      sha256 "57bbe2d358946e975fd11abd7501acb7b297abfce1e83fd86310b7a9490520e2"
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
