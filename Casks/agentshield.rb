cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.627"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.627/agentshield_0.2.627_darwin_amd64.tar.gz"
      sha256 "01f35712b3bc3ac84a9056471d9bd04eb60725b3bcc84adac971e1f76d0c7302"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.627/agentshield_0.2.627_darwin_arm64.tar.gz"
      sha256 "715d53c5eb67dfb1f1237cb688ccf459d0666e8881ed4e99b996ea7556bfdb9b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.627/agentshield_0.2.627_linux_amd64.tar.gz"
      sha256 "7f425c58aee47856d72b85136943e6a883a0e2d17c33430987ce84faed155a3b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.627/agentshield_0.2.627_linux_arm64.tar.gz"
      sha256 "9e5e0328350976df7eda8450da6238a3500b9b24f02792f168c6de901cfe983e"
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
