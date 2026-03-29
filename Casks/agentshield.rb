cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.222"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.222/agentshield_0.2.222_darwin_amd64.tar.gz"
      sha256 "dc0cf155ec6453447e4ac136d3f87f60cce1e24c2001f46c84439689a7fe8ebe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.222/agentshield_0.2.222_darwin_arm64.tar.gz"
      sha256 "6ea6be41b945c8d2cc3ae19aee31cd36976f7a6aa29593b34966bc10d7f67d9a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.222/agentshield_0.2.222_linux_amd64.tar.gz"
      sha256 "ceaada09c49d66608824a6220eda658acbdc7c94e0d00050e0ea0698d6fb76fb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.222/agentshield_0.2.222_linux_arm64.tar.gz"
      sha256 "66ddcb4b221ef55dd1f7319361b0c9198bbd27c545356a2cf5aaa4c0eb178b41"
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
