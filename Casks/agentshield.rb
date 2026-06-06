cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1231"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1231/agentshield_0.2.1231_darwin_amd64.tar.gz"
      sha256 "03340135791dd8c33a27fe32e5beab4e73486f7ea5c9f128dda01ce799546e94"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1231/agentshield_0.2.1231_darwin_arm64.tar.gz"
      sha256 "bbe5b7cd5418719b90d15185546055128779996cb90ef7841261d5555f49625d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1231/agentshield_0.2.1231_linux_amd64.tar.gz"
      sha256 "e376dcc76a29607bf7e74e319e4c415ee622158da085399f6505775a9284fcaa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1231/agentshield_0.2.1231_linux_arm64.tar.gz"
      sha256 "ffcf9e7c939ad90a09fc54703579dc0c8c58ea102f12953f889cc23b50b3c748"
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
