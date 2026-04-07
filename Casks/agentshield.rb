cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.481"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.481/agentshield_0.2.481_darwin_amd64.tar.gz"
      sha256 "1fbfeb2e1dd6230c8e0019ddfb4d1350591ae21b36c1e74ed9d6ffc23adcd6a8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.481/agentshield_0.2.481_darwin_arm64.tar.gz"
      sha256 "1967250fa6946240ddd85f4d0ccb720daf974cb7a6990d8b4f772eddf83daf27"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.481/agentshield_0.2.481_linux_amd64.tar.gz"
      sha256 "f01834ed9208eef5577443e87e81aa766347224cab66301eeb936b67ff7b4ac7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.481/agentshield_0.2.481_linux_arm64.tar.gz"
      sha256 "8ef2be0cebcb51bdea0e177a59fce0fa77cd00ba145ddb3435794561d583a2b9"
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
