cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.920"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.920/agentshield_0.2.920_darwin_amd64.tar.gz"
      sha256 "ab724a41627519e1c35ca99b9bb81a6c785981b38cb1beb60807749b659be421"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.920/agentshield_0.2.920_darwin_arm64.tar.gz"
      sha256 "3630e923f0967325dcb8b8d99f7398380c6a7526e2d12ad6e913f89677d2d54f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.920/agentshield_0.2.920_linux_amd64.tar.gz"
      sha256 "2da86e34d3a147552168dae0d7200e8cb1562af54811a58015fc2c8b3965362d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.920/agentshield_0.2.920_linux_arm64.tar.gz"
      sha256 "b99f690353ce73320da8633525ff377c2663fe5b899dd68163a25e0c67cdad71"
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
