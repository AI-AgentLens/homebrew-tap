cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2120"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2120/agentshield_0.2.2120_darwin_amd64.tar.gz"
      sha256 "714f34702900864220c152de41743bf6076bea07017deac104b8a7c811be2d67"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2120/agentshield_0.2.2120_darwin_arm64.tar.gz"
      sha256 "a994ad138994051f0410460e6d781a819862730a918bdbe79e7853fc53f78179"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2120/agentshield_0.2.2120_linux_amd64.tar.gz"
      sha256 "700e1f4d8c3d0ec126c1e300d19d9e4f84225742eeeb19b58963d9f1504d8df8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2120/agentshield_0.2.2120_linux_arm64.tar.gz"
      sha256 "d2b26912669277382bfd92400a4ab0caac6311aab420b79cc699b88b362ecb93"
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
