cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.363"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.363/agentshield_0.2.363_darwin_amd64.tar.gz"
      sha256 "228929bede24e38c3d2ee2717ac1cb22e80a30d9715af60b097c2b0712d02b60"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.363/agentshield_0.2.363_darwin_arm64.tar.gz"
      sha256 "2fd96bee9e1003bd33188cb99b245101c584615af6f31f35b1da38fb30f4a2eb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.363/agentshield_0.2.363_linux_amd64.tar.gz"
      sha256 "c4c2e6b415e688618ae6414882133776d123a00cdea6810379844784536fa0b8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.363/agentshield_0.2.363_linux_arm64.tar.gz"
      sha256 "50a58d8273103e407aec709e9d155b1efe78e9f1183c75dd66a157c8ded56e3b"
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
