cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2340"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2340/agentshield_0.2.2340_darwin_amd64.tar.gz"
      sha256 "4a08bd37d64a11a88584e59bbc3e2ef3f0e9762c278bc6684a2f4368f400b6f6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2340/agentshield_0.2.2340_darwin_arm64.tar.gz"
      sha256 "ae6c0e3c9c2a90f60e5e9ae68622114cdaa5fac51025117ffc8d4eb1cf963dc1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2340/agentshield_0.2.2340_linux_amd64.tar.gz"
      sha256 "e3486b20f5d595bd1cc66b8f35c7b811b46198d26d61844ab1394f312304fdf9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2340/agentshield_0.2.2340_linux_arm64.tar.gz"
      sha256 "8c8e6221eba22d2ffb74882a5e75dc8b7d5e5ee12e0fa8b454c1d9458cb92862"
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
