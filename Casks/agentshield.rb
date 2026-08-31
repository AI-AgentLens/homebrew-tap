cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2009"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2009/agentshield_0.2.2009_darwin_amd64.tar.gz"
      sha256 "2b803e3549c71ddc3da32cffc1867b4f63c76f1cfd700c06210351b3e4f30dc3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2009/agentshield_0.2.2009_darwin_arm64.tar.gz"
      sha256 "e9b054ecbb337e74c076eb3c4a20ad29916a71f1acaa8f3f0af64d5de5994a9e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2009/agentshield_0.2.2009_linux_amd64.tar.gz"
      sha256 "eea2314c4772bc22feb15cd0496aeb0bd73cd2a58572b812581a086bed10cc61"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2009/agentshield_0.2.2009_linux_arm64.tar.gz"
      sha256 "23a705f751cf9a8da3fe99dcdb24cc8f9a7960489f502f4cc87152ab9a92d03b"
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
