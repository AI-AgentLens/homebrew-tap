cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2409"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2409/agentshield_0.2.2409_darwin_amd64.tar.gz"
      sha256 "2379f81978e8203ef4400d73b0dda9b9b393fa87979a82234848e97f8ba81528"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2409/agentshield_0.2.2409_darwin_arm64.tar.gz"
      sha256 "8e4abee39c761e6124854e2d5cfc955913c8fadaa1062b8627852202238eb2d0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2409/agentshield_0.2.2409_linux_amd64.tar.gz"
      sha256 "096674061385d93d1ffde64896010c44d034c0aad359b4c0958c6d61b5703cbd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2409/agentshield_0.2.2409_linux_arm64.tar.gz"
      sha256 "b98230259988994521acbcda7a7b480a6472049b43804e22b223cf8c74a3c0b8"
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
