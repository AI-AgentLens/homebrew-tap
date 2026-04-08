cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.499"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.499/agentshield_0.2.499_darwin_amd64.tar.gz"
      sha256 "8054b28f18c41ca2c50f0244b8a154ec9daa2b9bbf5214765ca9ed8f57470a22"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.499/agentshield_0.2.499_darwin_arm64.tar.gz"
      sha256 "121499dd3f77fa33f0e01ffc0d42d7864b97784d09affd2e6633645719ac992a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.499/agentshield_0.2.499_linux_amd64.tar.gz"
      sha256 "7f8897514720befeca4260550b0f5bcc87975f15a6f8d406bb6a92b8bf8745e2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.499/agentshield_0.2.499_linux_arm64.tar.gz"
      sha256 "109282cd852b2c62e5f83026b754d41bd7047e5b73d03e1b23f6079c199cbd3e"
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
