cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1209"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1209/agentshield_0.2.1209_darwin_amd64.tar.gz"
      sha256 "570e233b409f4bf0db8b71afa304b1385b5b7976b479a44f0b9dad7863b520be"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1209/agentshield_0.2.1209_darwin_arm64.tar.gz"
      sha256 "3f6d6c149fbd256327bfeb962a8f1dc74c2ddc7dd82ebbf980623c7a2ec8f1f9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1209/agentshield_0.2.1209_linux_amd64.tar.gz"
      sha256 "7df3c79a8f73dc3fa38a290c55c2c601d505b6ee2a4a8976cc6ff59df8516898"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1209/agentshield_0.2.1209_linux_arm64.tar.gz"
      sha256 "b88893175d94c7ae69f4c47168a5a66db500ac7aebbca5d759f06b9366612467"
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
