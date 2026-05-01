cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.840"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.840/agentshield_0.2.840_darwin_amd64.tar.gz"
      sha256 "2fb647088c3f05307acaf41e072e7325969f931a04c1ab0593b50b923bd89992"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.840/agentshield_0.2.840_darwin_arm64.tar.gz"
      sha256 "7fc88afa9e6fae09452a2fa595834511b0e0b5b9104f0c8a02f4128692a5956a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.840/agentshield_0.2.840_linux_amd64.tar.gz"
      sha256 "1cf3cd560f9b7163d4f59b43a02655c0247efbd04b4c9f57a9f7b2377df3f1d0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.840/agentshield_0.2.840_linux_arm64.tar.gz"
      sha256 "9a92c970431f92840c166f89d9fe0c49d41974a29a0e17393f49733389653ef9"
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
