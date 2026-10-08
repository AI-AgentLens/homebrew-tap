cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2381"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2381/agentshield_0.2.2381_darwin_amd64.tar.gz"
      sha256 "8aa7ceefbb685cf47722a6967b63cbcb424e0780a4f24b5740a98a39def7e720"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2381/agentshield_0.2.2381_darwin_arm64.tar.gz"
      sha256 "ab26ecf95bb3877fe10e501cbf8034ff36686c44d4e6eb033e864d767656b987"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2381/agentshield_0.2.2381_linux_amd64.tar.gz"
      sha256 "ca64722a7831ad761cbd91f14cb8a60c14efb438fa2259b7c84601bccd5e6112"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2381/agentshield_0.2.2381_linux_arm64.tar.gz"
      sha256 "bb078634bffe55ba9230e8638507fff83cd6ec7ac3aad1d84c4e73955e62f30d"
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
