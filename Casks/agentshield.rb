cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1160"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1160/agentshield_0.2.1160_darwin_amd64.tar.gz"
      sha256 "e938789c18780224f71eb402be7bfe25b6448c2aea8454a0f9d99436450f025b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1160/agentshield_0.2.1160_darwin_arm64.tar.gz"
      sha256 "1babedc4860429d2aa2f779fa6b4f2af73124424f8ee1d5484de9874578ad505"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1160/agentshield_0.2.1160_linux_amd64.tar.gz"
      sha256 "987204d81f4fc8aed45044ee1242be50d6c42ec583ff9bc9caecfdefc7b6b8bc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1160/agentshield_0.2.1160_linux_arm64.tar.gz"
      sha256 "72812ed0009112a4950d0df5c20e604b4307f534a249a1f52b280b63424bfab6"
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
