cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1637"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1637/agentshield_0.2.1637_darwin_amd64.tar.gz"
      sha256 "dc6f84b3fc51d8ac41cae52655c8632df93d73fcfd07c3defbcf15300bb19a94"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1637/agentshield_0.2.1637_darwin_arm64.tar.gz"
      sha256 "72c8700a0d6e2e242b44510a826561d71162124b14ae40a958e8b78030cda123"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1637/agentshield_0.2.1637_linux_amd64.tar.gz"
      sha256 "85b8fa32989229d6f6f47b3079ba960ef957673d14d915160016b70764285410"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1637/agentshield_0.2.1637_linux_arm64.tar.gz"
      sha256 "fa298ae7eb63f1f34c4e0deeda37755183be0b3a981ace780893328ef2202a01"
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
