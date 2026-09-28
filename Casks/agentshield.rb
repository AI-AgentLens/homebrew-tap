cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2274"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2274/agentshield_0.2.2274_darwin_amd64.tar.gz"
      sha256 "1e0c29825aec9b294581e3ceae0c94a64526d65fea82def5f9453468f2683df4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2274/agentshield_0.2.2274_darwin_arm64.tar.gz"
      sha256 "72174f8e9caa79508c3f6331ca92d0ce0de7ca3ec14b08e521ae402df8fb9053"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2274/agentshield_0.2.2274_linux_amd64.tar.gz"
      sha256 "325f059e161fd61bf5cca9f926c9af7815a20fe5cec26477f660a4b349f65294"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2274/agentshield_0.2.2274_linux_arm64.tar.gz"
      sha256 "45ceabf860608fd0e5d0763ee5d1043eba3f2d6bc0a0578a5523f455155d3f88"
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
