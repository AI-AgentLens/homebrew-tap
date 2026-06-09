cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1256"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1256/agentshield_0.2.1256_darwin_amd64.tar.gz"
      sha256 "28f1195833b5649e09f64f4cd224a4fd6b2b8ab8dd524b3d70630b65c933dfa2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1256/agentshield_0.2.1256_darwin_arm64.tar.gz"
      sha256 "0c1274b623101a7c820063a24d7647c5a47be06687b1f768c31f6b3b6954bd5e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1256/agentshield_0.2.1256_linux_amd64.tar.gz"
      sha256 "dd8b3c209e536384ce34e4da0c533c3751e40474f19bc6cb44dc01cf61c47971"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1256/agentshield_0.2.1256_linux_arm64.tar.gz"
      sha256 "8aa737dfad7a8bb4552c7ee967526dd85583834a5cda9f5b4c7ffb85c99fba8b"
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
