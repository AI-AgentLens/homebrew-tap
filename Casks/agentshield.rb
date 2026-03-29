cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.187"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.187/agentshield_0.2.187_darwin_amd64.tar.gz"
      sha256 "45947d795688911ff42eef4a37d9333b99ed5d7dea53b3612ae303b90d97a8c8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.187/agentshield_0.2.187_darwin_arm64.tar.gz"
      sha256 "8549cb482c9ba4f3bb42d3463f97c9677553ce262119cee21875ce71c14ddb3e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.187/agentshield_0.2.187_linux_amd64.tar.gz"
      sha256 "826e5a6dde58094ae7e3fff7e0f0ffb7ca16c2935a1689025d42e77e0f96872a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.187/agentshield_0.2.187_linux_arm64.tar.gz"
      sha256 "2a5e02cf3aae1d0e1df1824a994b4e56b96909a0ef3102a11c21be0c7ba1789f"
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
