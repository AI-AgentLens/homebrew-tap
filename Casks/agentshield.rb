cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1735"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1735/agentshield_0.2.1735_darwin_amd64.tar.gz"
      sha256 "63b7423fce3b890f74c623cad23fad0bf2adebf2c0a273b431a4307a956def28"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1735/agentshield_0.2.1735_darwin_arm64.tar.gz"
      sha256 "f25bbbfc836c875a4fc537b8edc5d537bfd16e91ae9635981cdaae6f9be285fd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1735/agentshield_0.2.1735_linux_amd64.tar.gz"
      sha256 "418ffb2b5e13cc1601068f506aa3008554866aec340199e0deda55bac95f1e18"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1735/agentshield_0.2.1735_linux_arm64.tar.gz"
      sha256 "fad9c5a0ffaecf58ce532819c71842f5c98ce6d224ebfbae7aed9e8f424cda84"
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
