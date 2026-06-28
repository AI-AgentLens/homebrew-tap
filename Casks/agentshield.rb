cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1477"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1477/agentshield_0.2.1477_darwin_amd64.tar.gz"
      sha256 "fa1b80d601c3f450744e451ba42aa3d480c6b934544b80f2bf66b1777113f523"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1477/agentshield_0.2.1477_darwin_arm64.tar.gz"
      sha256 "500041d1e65e35e3e589f31012f372c89c10c8e67a4463d27461b6a7ca94a190"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1477/agentshield_0.2.1477_linux_amd64.tar.gz"
      sha256 "2164fe27792a57d247de7c6e5778c98f1401d749642a63146c8cd11ac2f79e71"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1477/agentshield_0.2.1477_linux_arm64.tar.gz"
      sha256 "26b91f99eed0a6940d566e5174b7912676c3b5332ce81f8110dd1274a1bc1572"
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
