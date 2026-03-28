cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.175"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.175/agentshield_0.2.175_darwin_amd64.tar.gz"
      sha256 "f8771f29d5c5477e59d084a7620100ae0cf9c3349f147dfa7751a69ed31cff23"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.175/agentshield_0.2.175_darwin_arm64.tar.gz"
      sha256 "c73497e5e711f3c5bb8e8d325abe3ba753933ecbf24eb4f09d8e9bbb3f361b1d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.175/agentshield_0.2.175_linux_amd64.tar.gz"
      sha256 "44f8d99b10ab3f8b1fc90817277c816bd4a94ffc49bdc10a8c471aecf01efa52"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.175/agentshield_0.2.175_linux_arm64.tar.gz"
      sha256 "b8548829a2edd65ba71a6a7604e3237f5c357f16e05840816150453368c5afb9"
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
