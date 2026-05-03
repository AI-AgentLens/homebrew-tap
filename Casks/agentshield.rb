cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.862"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.862/agentshield_0.2.862_darwin_amd64.tar.gz"
      sha256 "28ced0b272aa68be17696a557b1dae68d60270b94d2ac1c47aa94f87946a72ee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.862/agentshield_0.2.862_darwin_arm64.tar.gz"
      sha256 "4e0d8359964daa9cde5abb395a86f95dded13b0b5356c76ff714a8239d081cf8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.862/agentshield_0.2.862_linux_amd64.tar.gz"
      sha256 "d3cc76a0a8390c058a0f6c858b663a78d4c67684556f01c98e8d8adad9895401"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.862/agentshield_0.2.862_linux_arm64.tar.gz"
      sha256 "94f56980e6cba5a4ff65c8ec4bfdb49f82f50fee96e4b96d0bab999a5c9232eb"
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
