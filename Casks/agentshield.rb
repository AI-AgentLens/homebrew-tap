cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1745"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1745/agentshield_0.2.1745_darwin_amd64.tar.gz"
      sha256 "63a27d9f96baaba5e0da933d8cd29757c1d94cf8b7d9740af9a4272d47fae4a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1745/agentshield_0.2.1745_darwin_arm64.tar.gz"
      sha256 "9cff7c9d53e9b98b3298844e84e35ddce7d44d93464f2de6b276a5210f2e3799"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1745/agentshield_0.2.1745_linux_amd64.tar.gz"
      sha256 "9ddab5a4da7bf6fa41925af9723dbb2ec1f2c92654ee1fe8de714a28f6468f90"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1745/agentshield_0.2.1745_linux_arm64.tar.gz"
      sha256 "9607bc3dd2af3d4f795d9b74f76b679358ca1da2c54f32106619cef010a39969"
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
