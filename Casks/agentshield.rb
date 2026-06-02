cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1192"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1192/agentshield_0.2.1192_darwin_amd64.tar.gz"
      sha256 "ad6f927cda42a7e733e0c6ba251d69c6c863d98d87de05022953b61e8a1a3db2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1192/agentshield_0.2.1192_darwin_arm64.tar.gz"
      sha256 "95d19a802f0ee40b145f71c27bd31a45349f5e5a6e8265f2bae8065c063f6217"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1192/agentshield_0.2.1192_linux_amd64.tar.gz"
      sha256 "3a6b5fadfb370bb12bc2fb742143b3abf288b0a1d9a20cfcdfe7ed97599e11d6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1192/agentshield_0.2.1192_linux_arm64.tar.gz"
      sha256 "fe92a726c203f1b3d011e46008765866d0ead0046d4dcdd21430174061bce956"
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
