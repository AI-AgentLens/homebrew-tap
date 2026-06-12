cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1288"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1288/agentshield_0.2.1288_darwin_amd64.tar.gz"
      sha256 "dd71b6cab072ffc590a6e693ba6b93da045e60b2c61a7c6828edb81e79f71dcb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1288/agentshield_0.2.1288_darwin_arm64.tar.gz"
      sha256 "84f7ec174a86a13e2a54cb74132ba8d1cbb1ed8443b0c6bbe882bcf57b61fb73"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1288/agentshield_0.2.1288_linux_amd64.tar.gz"
      sha256 "87e475232126303d6449829710cbcf4e5d98b6e7da72a59446d429d8add14a1f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1288/agentshield_0.2.1288_linux_arm64.tar.gz"
      sha256 "3b3e015b7cb10d1abaecdc6f4c75ac5d35d366aa42ea4bc0f6c2fbdedfaa4c6f"
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
