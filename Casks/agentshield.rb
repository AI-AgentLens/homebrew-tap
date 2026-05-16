cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.993"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.993/agentshield_0.2.993_darwin_amd64.tar.gz"
      sha256 "a4b18fc91822b5b85978d3ada908ad13b236b4b63351b73e3bf6b432aaf76a71"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.993/agentshield_0.2.993_darwin_arm64.tar.gz"
      sha256 "e813899758b09d634fd18f76f5207ffb194168e393c246f54cf9c53ef4197339"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.993/agentshield_0.2.993_linux_amd64.tar.gz"
      sha256 "c3e48abb5b9d32bd7effd0c5d9d617ed17ecf774ce9b73e65548d31adcc1f22a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.993/agentshield_0.2.993_linux_arm64.tar.gz"
      sha256 "07cf996c3e52b6cf03ed1926bb2a5b5242002533f870a2b707edaa87f43baa37"
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
