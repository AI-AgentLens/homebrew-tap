cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1182"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1182/agentshield_0.2.1182_darwin_amd64.tar.gz"
      sha256 "46b5ba944c95aaed42a7120b667f65bf8f9f85ea564370b95ebc94daa93d12da"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1182/agentshield_0.2.1182_darwin_arm64.tar.gz"
      sha256 "9d64fda096cfd0ce9ca65dc03c1c40252ea9503c3c6e2b05377d89c3d8237cf4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1182/agentshield_0.2.1182_linux_amd64.tar.gz"
      sha256 "721c4869fa6a019c39677bf75e1e4242a5fd0b2bee6fd5d989a4caef1d38a82a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1182/agentshield_0.2.1182_linux_arm64.tar.gz"
      sha256 "35766f0a06c39308359289f8ab825d3b0f23774c503401fee0459f23d5106118"
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
