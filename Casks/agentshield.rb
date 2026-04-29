cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.822"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.822/agentshield_0.2.822_darwin_amd64.tar.gz"
      sha256 "244b57ee8cb0878790ab55adef6666763e14686c3c8373c76265d44dfa984468"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.822/agentshield_0.2.822_darwin_arm64.tar.gz"
      sha256 "e0d75b12978c43364a058249845ffde17ec23838f16196981c98e1436876415b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.822/agentshield_0.2.822_linux_amd64.tar.gz"
      sha256 "9bb4b67f7c6e52350b8be4fabf0f1e68a61ae5cb0ddba175dd8b195ec7630ac2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.822/agentshield_0.2.822_linux_arm64.tar.gz"
      sha256 "0af3c1ea4a5d075a12b0d5aaf6e1cb36d56e19c0f3554e4f695c29ff2f556844"
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
