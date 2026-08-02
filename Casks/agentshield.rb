cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1774"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1774/agentshield_0.2.1774_darwin_amd64.tar.gz"
      sha256 "d3e42c7c0dc8e98a58ec3069dbc742c0f45035c20689de45ec2f4b3b572f5bd2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1774/agentshield_0.2.1774_darwin_arm64.tar.gz"
      sha256 "7fa638ccee7a039c5eee13829e50ddb5265adbf2637d7d200ce5b58dc66e0860"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1774/agentshield_0.2.1774_linux_amd64.tar.gz"
      sha256 "9a852f32ab1c0493d76ce881ed8abac4770661f46e63608dd6bb7b9747179507"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1774/agentshield_0.2.1774_linux_arm64.tar.gz"
      sha256 "c0acc4ad722da036b1dd821b613d167ba4e4704a626688b47acadc29c6a2f349"
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
