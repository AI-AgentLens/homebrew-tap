cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.801"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.801/agentshield_0.2.801_darwin_amd64.tar.gz"
      sha256 "0dea67bf02cdfb8299b565f15a69c42b173d1bbe21cea917b969a8180fa3649a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.801/agentshield_0.2.801_darwin_arm64.tar.gz"
      sha256 "3a237d98ced0a60e2450c2895bd0e391cfba5b3084b665a12c0c1ea3e50c6a9b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.801/agentshield_0.2.801_linux_amd64.tar.gz"
      sha256 "8d386d2a405ed7c898d3194ab8d93ab1a81f9c3b545c09b69c837bf292a89679"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.801/agentshield_0.2.801_linux_arm64.tar.gz"
      sha256 "24292583da30fd1825b6058d52be3eff5c17aed48ba544007fc0d5386f1319db"
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
