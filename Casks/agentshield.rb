cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1399"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1399/agentshield_0.2.1399_darwin_amd64.tar.gz"
      sha256 "b8cca85f59061c722e903c926670eceb65d53270f5f4b6e8afb1159cc07b9692"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1399/agentshield_0.2.1399_darwin_arm64.tar.gz"
      sha256 "c3edb5cd6d9eb00022d4e690d9dd6113305ceec604fe527696af166e49a9d626"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1399/agentshield_0.2.1399_linux_amd64.tar.gz"
      sha256 "94021ca3b2892f0d2e57cba5012df18f4d280f13ed1c94ac1bae8836e272c4d3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1399/agentshield_0.2.1399_linux_arm64.tar.gz"
      sha256 "ef4e8e437e916ad86883fd7896a705d1af38f729356226e41966c2dc9c8b40a3"
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
