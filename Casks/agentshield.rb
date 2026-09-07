cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2076"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2076/agentshield_0.2.2076_darwin_amd64.tar.gz"
      sha256 "c3a77a3c63b03bf8d5a7825b6017584971d167ddf6d0266f17e67a8b36f02c7b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2076/agentshield_0.2.2076_darwin_arm64.tar.gz"
      sha256 "1bf75df1e24b8afbd8e0d403f5bacef6fc39ff149e8d3aad1967929c4272a875"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2076/agentshield_0.2.2076_linux_amd64.tar.gz"
      sha256 "9636f9c892cf8cc17b2748ce87199c54a8d96d310375f06d7180dac2a94c393d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2076/agentshield_0.2.2076_linux_arm64.tar.gz"
      sha256 "9fe0b8b7507c71db2ce8b8df2dd74ccfca88977b376b044b8e52a7c220c663e5"
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
