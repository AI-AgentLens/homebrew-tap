cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1162"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1162/agentshield_0.2.1162_darwin_amd64.tar.gz"
      sha256 "6f70d4a3e6d0aaddd0e29e0859dc0d6194cc5c24781a7c2a7cbd7fa907adafa7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1162/agentshield_0.2.1162_darwin_arm64.tar.gz"
      sha256 "93f3f9800d1be6eb924e2a241fb28b2f2640d7cba981aef8211d41d3d402b2ba"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1162/agentshield_0.2.1162_linux_amd64.tar.gz"
      sha256 "f3826d1e113f8f6c3ee5780d79db04494e37d2dbfa03f73f988be3404a79e757"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1162/agentshield_0.2.1162_linux_arm64.tar.gz"
      sha256 "4da40684bacf2cad59c69999489a37bd3d16300a39f2b9b50feb7492120aec23"
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
