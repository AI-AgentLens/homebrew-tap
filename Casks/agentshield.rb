cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2426"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2426/agentshield_0.2.2426_darwin_amd64.tar.gz"
      sha256 "5ff1a4b8ac6a7bc221c36571dbb072e6482c44972be97975abb143843dc4de64"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2426/agentshield_0.2.2426_darwin_arm64.tar.gz"
      sha256 "538326ec165e2dc158e8063afba996c9ce48907a68618960322c69d2a9466d30"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2426/agentshield_0.2.2426_linux_amd64.tar.gz"
      sha256 "27965ccec4c16687a8dd052ce4a18ace60d180d47395a19d9fa32a59890d4e43"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2426/agentshield_0.2.2426_linux_arm64.tar.gz"
      sha256 "226c32a211a3931b99753f334d8422fd6565d23fb6b37790d3e2507b884bb26a"
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
