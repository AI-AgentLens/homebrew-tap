cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.640"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.640/agentshield_0.2.640_darwin_amd64.tar.gz"
      sha256 "1faa065e58ef0f34c2f94c5e4f34a1aff6a38990f3ea8507fe55c03181d9d982"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.640/agentshield_0.2.640_darwin_arm64.tar.gz"
      sha256 "0fd7b937ba15946819aef19d51956e8b3ea5ed62150c1682c0cd67a7484d8150"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.640/agentshield_0.2.640_linux_amd64.tar.gz"
      sha256 "2891217aa9aa478bfc58a8b427365233c31c5fdf14a92bdc7f3d9f963d2a020e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.640/agentshield_0.2.640_linux_arm64.tar.gz"
      sha256 "828548c75e31ee2d1ec019cd78b05d074aa0210a4cbed23c1639a3c8ba70f409"
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
