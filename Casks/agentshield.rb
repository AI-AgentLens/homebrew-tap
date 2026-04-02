cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.329"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.329/agentshield_0.2.329_darwin_amd64.tar.gz"
      sha256 "78f10a5bdb8729d581e68e7af6ba576a109533e97a1852cfd2b51ac63f58364e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.329/agentshield_0.2.329_darwin_arm64.tar.gz"
      sha256 "ac245b42c05dc725d29d59cc086bab40d5235a02b722c802c7fae95531b466ff"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.329/agentshield_0.2.329_linux_amd64.tar.gz"
      sha256 "3b2e599944782f0a89ffd72c92b29d1cfb0b5f236a661d31851af5b432672367"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.329/agentshield_0.2.329_linux_arm64.tar.gz"
      sha256 "75b92540aff666b753598fb058795a6e37f1fcfd0ac9213479e2fc2f1df9ab1c"
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
