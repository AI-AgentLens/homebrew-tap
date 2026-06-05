cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1213"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1213/agentshield_0.2.1213_darwin_amd64.tar.gz"
      sha256 "a90eb79cca81dbe3c9e5966678833f85e4ae3b226616d7de962c6f917991353c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1213/agentshield_0.2.1213_darwin_arm64.tar.gz"
      sha256 "b3678b2c469eaf7d32636641463b1e305a824b4f5cfc856908d30e37d991a856"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1213/agentshield_0.2.1213_linux_amd64.tar.gz"
      sha256 "eca979873c74e9a11311e5c3d70091a581a17984973eec482dec1b4b3740b2fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1213/agentshield_0.2.1213_linux_arm64.tar.gz"
      sha256 "01020aef3c5b9f3704a1647f20fafd4ca730f245e84d92cfbfceb6709b51df93"
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
