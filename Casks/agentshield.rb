cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2181"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2181/agentshield_0.2.2181_darwin_amd64.tar.gz"
      sha256 "3f7a19f3e753df2c6f0a4ba7a74cffe0f64eae26d801fb8da06d7a479508dbce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2181/agentshield_0.2.2181_darwin_arm64.tar.gz"
      sha256 "1c45e8c540f5fd9be59ebb565f1b624149ac09f37a8531985eb54f58867a6ad9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2181/agentshield_0.2.2181_linux_amd64.tar.gz"
      sha256 "923a0edf9f742b8285345f495f02f8c97f82064a12a85ee4115f004217af427b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2181/agentshield_0.2.2181_linux_arm64.tar.gz"
      sha256 "af02ffaa00fcdee0e53201e3810aca010b84d709a0bfa5170a79b168f68ceb67"
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
