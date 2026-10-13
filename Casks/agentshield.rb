cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2421"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2421/agentshield_0.2.2421_darwin_amd64.tar.gz"
      sha256 "4055a4529a3d2fdc9649cce09fa1903fe8fcb178422da878e57dd010b7106771"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2421/agentshield_0.2.2421_darwin_arm64.tar.gz"
      sha256 "4fe49596236d48468474d6cfe4164c9fb0d790be79c576a751f5ece66f2a0bc7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2421/agentshield_0.2.2421_linux_amd64.tar.gz"
      sha256 "29e1f71da88d2f5d2c2f95d288c0742afcd871af8ce3fd5cd8ab181681976e1b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2421/agentshield_0.2.2421_linux_arm64.tar.gz"
      sha256 "3c00536e2a03cb1d4dc5bd5d3f429fafa85fc181e9d942630e5b7a460236ca22"
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
