cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2447"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2447/agentshield_0.2.2447_darwin_amd64.tar.gz"
      sha256 "cf4296103f1fbd9dbea73ff21a5621f106edda50ffc3f6dc16d9c1eda765bb4b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2447/agentshield_0.2.2447_darwin_arm64.tar.gz"
      sha256 "972ce76c6b9864dc4bcaa5187481a865e5aef7c375ee19df1c0ba895bf81b808"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2447/agentshield_0.2.2447_linux_amd64.tar.gz"
      sha256 "e249dcbe1157d035841abe37a5b28c5f13fc075d963a86e5e26450e30bc2af7a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2447/agentshield_0.2.2447_linux_arm64.tar.gz"
      sha256 "9ee76b755295acae61162bc802c6a96c831c71ab51bc7b8f8956d225e3e2aa66"
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
