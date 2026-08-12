cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1827"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1827/agentshield_0.2.1827_darwin_amd64.tar.gz"
      sha256 "68956180fc3a0d3c1c23c654c25d5408e46e189e32f6a6b9c44369804356a163"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1827/agentshield_0.2.1827_darwin_arm64.tar.gz"
      sha256 "d3fb0b6c5abc94a966874276925de1e6781fddc25af3bf0a33d62a1ff2386b97"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1827/agentshield_0.2.1827_linux_amd64.tar.gz"
      sha256 "ee47c1f95d5782af8892ef6fc6eeb97a9095f0382b5f3c819aaefe09579b7b6f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1827/agentshield_0.2.1827_linux_arm64.tar.gz"
      sha256 "2a09faa880a4bbf4fa4a7ac07706c81d2228272d8873b58e88cecd3428a51f3b"
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
