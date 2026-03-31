cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.265"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.265/agentshield_0.2.265_darwin_amd64.tar.gz"
      sha256 "8fd2c7ed6e2af752c63bfd1ce11f11867e23868c8e08b176ec2d070fb8a7d825"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.265/agentshield_0.2.265_darwin_arm64.tar.gz"
      sha256 "eff6b20305f6b6ee49413d6ff6dd9321230f76576c455e15e3958146f2eca057"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.265/agentshield_0.2.265_linux_amd64.tar.gz"
      sha256 "81b42468245ac95da6c831a131506fb5f28ff574866116802668e26ba8ef7db0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.265/agentshield_0.2.265_linux_arm64.tar.gz"
      sha256 "7fda30a8a65f827b741bc34fb162ddb51364b3f5e8705a0d4820006fb8e0fe42"
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
