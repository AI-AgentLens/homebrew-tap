cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1968"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1968/agentshield_0.2.1968_darwin_amd64.tar.gz"
      sha256 "4371ab1f6bd1d008a6f5f157c4a3cc7a4fd09e6c24b8baeae5d3e4bccda0adb7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1968/agentshield_0.2.1968_darwin_arm64.tar.gz"
      sha256 "b0ea6cdefb1df6939c71ab404b7ad7a9ce521c32101b9edb8ae6d81bd80c44ad"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1968/agentshield_0.2.1968_linux_amd64.tar.gz"
      sha256 "40909109be9f4d38e625ecaaa93f68987e1f62cb0ad5197dfd517b0a048cad73"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1968/agentshield_0.2.1968_linux_arm64.tar.gz"
      sha256 "4b028326b4614b64965a679f50256338688c55ac994d8434204a69153a20d6f4"
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
