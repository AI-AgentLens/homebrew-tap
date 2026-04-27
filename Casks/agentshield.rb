cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.768"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.768/agentshield_0.2.768_darwin_amd64.tar.gz"
      sha256 "8807926616926d22a93e36c67673c68eac9df3d757c5a7ab9176b4c2ceaa8b80"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.768/agentshield_0.2.768_darwin_arm64.tar.gz"
      sha256 "ece478f753643a50f64c602e6e10cb8245f5f6dc14015fbca52e7be56dd2501b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.768/agentshield_0.2.768_linux_amd64.tar.gz"
      sha256 "b66e9fc657c84caf80dc282de80f423d83e4fb932ced221cb3c6e2da27fa60cb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.768/agentshield_0.2.768_linux_arm64.tar.gz"
      sha256 "bfa63445c656cc82cafc62c9806ef13516e5ac029a10068cc22b641d732966b9"
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
