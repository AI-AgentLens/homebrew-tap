cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1687"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1687/agentshield_0.2.1687_darwin_amd64.tar.gz"
      sha256 "ff189bc9f18812a7cddf353afb8db0c7e698046f1e213d2cd56c4f660186bac6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1687/agentshield_0.2.1687_darwin_arm64.tar.gz"
      sha256 "f8d5d06b4f0bcc04b7a60d76f7fbd1e752ca8e3e5917dc5585207b0ead455f14"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1687/agentshield_0.2.1687_linux_amd64.tar.gz"
      sha256 "3722ea48d4cbb2cbcbf3765bafc7e3657c255d98d5bc8984644ae44a8c035263"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1687/agentshield_0.2.1687_linux_arm64.tar.gz"
      sha256 "76acef991d8c42ead1029edf61b7c1a47a7768a1223d2c6711606f7372aae162"
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
