cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1033"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1033/agentshield_0.2.1033_darwin_amd64.tar.gz"
      sha256 "cc7c7138547468f7567dd79c8cf44db902796c4572b834fc45bbe1a27859ba6e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1033/agentshield_0.2.1033_darwin_arm64.tar.gz"
      sha256 "32360464eb666e6206e2f6f8caa0d914133f3d6ee09d885960b4a23c1adb008e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1033/agentshield_0.2.1033_linux_amd64.tar.gz"
      sha256 "426527415bb19e0635ba62891b296b206bf7f6689ca1bdd3c2c0434723f81afd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1033/agentshield_0.2.1033_linux_arm64.tar.gz"
      sha256 "1162c5266ab34157372d6ce5e826dd3374e038db0b3334bcf9f4664ddfa4beda"
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
