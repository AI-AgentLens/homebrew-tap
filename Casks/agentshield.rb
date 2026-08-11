cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1817"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1817/agentshield_0.2.1817_darwin_amd64.tar.gz"
      sha256 "088994e4b263379627c34a56ec0c9388bda08918fa4f04cc1a9e0f568411ba32"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1817/agentshield_0.2.1817_darwin_arm64.tar.gz"
      sha256 "1873def9e85401e33eafb25cdc91954919fb4a50b914a19f4c536e6b83351333"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1817/agentshield_0.2.1817_linux_amd64.tar.gz"
      sha256 "1725d20462570e2f4366f767d7e72651bb04fc752f8f6fb6538129c766c8f81d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1817/agentshield_0.2.1817_linux_arm64.tar.gz"
      sha256 "e6eb9940f660c01f563a7390352417a2f5ad4d530aaea8cc78f6e7057ad066c4"
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
