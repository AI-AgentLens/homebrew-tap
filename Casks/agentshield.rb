cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1185"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1185/agentshield_0.2.1185_darwin_amd64.tar.gz"
      sha256 "1473e41b8fbf92a9b40b871866f1adf6c03be265d0616f2c6ae97f3ad4e17675"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1185/agentshield_0.2.1185_darwin_arm64.tar.gz"
      sha256 "1875465c5a0053c3319341550eddc0ad32d4663ec9140631fe4f6ac6a138d5b5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1185/agentshield_0.2.1185_linux_amd64.tar.gz"
      sha256 "ebf13c37bff97b042baa1b35d47e488d174e84354f80c2d3f1ed3cc02b423b5d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1185/agentshield_0.2.1185_linux_arm64.tar.gz"
      sha256 "5c9117d56b99c880acea48baa6b10d19812df65b21fc199b0fb281577e74d337"
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
