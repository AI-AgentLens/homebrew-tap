cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.356"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.356/agentshield_0.2.356_darwin_amd64.tar.gz"
      sha256 "6c92f23bfccb7a4a12657eba602b90d045df2a05e5072d67e4f0391e2622577d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.356/agentshield_0.2.356_darwin_arm64.tar.gz"
      sha256 "fe7f3fc6ca70fe49a686842459c2ceb2ddfb857efde46ac9683eab19dc095e84"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.356/agentshield_0.2.356_linux_amd64.tar.gz"
      sha256 "504c466bb6302b0841f1af17a5a4da3215745f4b863586eaecd86c670b33e8a9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.356/agentshield_0.2.356_linux_arm64.tar.gz"
      sha256 "da019f098beab47d0fb5d96d7e1ac699567cf71aad61a344a6134842ff6b7b75"
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
