cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.145"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.145/agentshield_0.2.145_darwin_amd64.tar.gz"
      sha256 "a57cca9749aa2ee8d58077446420b9206eac8c266b65c0e2882c7c0dc7544125"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.145/agentshield_0.2.145_darwin_arm64.tar.gz"
      sha256 "0aeb6498aadb3aa7d9638de476d4accb97c55a6e72cd754c5d53dd448181963d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.145/agentshield_0.2.145_linux_amd64.tar.gz"
      sha256 "acd9ab72939a5de4dab8db1cf81f9f635a62ac837825747cbcab1a670ed03a4e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.145/agentshield_0.2.145_linux_arm64.tar.gz"
      sha256 "5204c2d1929f73e431a6f3a716d6b07fa075812c9d607fead8973b0ad038fa51"
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
