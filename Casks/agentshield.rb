cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1515"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1515/agentshield_0.2.1515_darwin_amd64.tar.gz"
      sha256 "ae2caa697b3e7c3dd36242d86529c206bcee3bd2b95742fd99d7d2b7e461050c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1515/agentshield_0.2.1515_darwin_arm64.tar.gz"
      sha256 "719004d3aecbcfc21940fd196b44e775ae3ac9fd05b9d70e53fce204cc19f2dc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1515/agentshield_0.2.1515_linux_amd64.tar.gz"
      sha256 "823329a9923b00c80e8a5c561bcd91b4f2e1eaefcb5815526e56bbfb867527ca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1515/agentshield_0.2.1515_linux_arm64.tar.gz"
      sha256 "7cefd07ebcf79b3653a448feea77ddbe0f187bedd0b5dce0ddfc756fb78df10b"
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
