cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1758"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1758/agentshield_0.2.1758_darwin_amd64.tar.gz"
      sha256 "9bf43a7bfc647d40c7b270386247a09f46cab7dc5e9327edf10a5780ab5d865d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1758/agentshield_0.2.1758_darwin_arm64.tar.gz"
      sha256 "c70b68fe81ff3d6df5daba3e62a562812ca0f3a3f05928c361985df9370f48a2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1758/agentshield_0.2.1758_linux_amd64.tar.gz"
      sha256 "f1d62586e0b052561e4dd87d8015992c43dc595c983a4a56e604b8656ab09190"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1758/agentshield_0.2.1758_linux_arm64.tar.gz"
      sha256 "285746568ea53c1d3c2f5c4682113904ffa85bd0fe7d2166b523070c16ac1090"
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
