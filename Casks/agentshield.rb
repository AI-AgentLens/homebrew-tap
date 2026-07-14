cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1644"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1644/agentshield_0.2.1644_darwin_amd64.tar.gz"
      sha256 "8ab3d0ed66cb3287a836be4d9f2066852bc6036a6bcf00365f940584c7f6098e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1644/agentshield_0.2.1644_darwin_arm64.tar.gz"
      sha256 "5ede272b9d9d956cffaca6ea7634004618b008e41e2a795bac8b1644ad0812d3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1644/agentshield_0.2.1644_linux_amd64.tar.gz"
      sha256 "fe43abe462aaa945502f6a76bb08b1f80d5c303bbdc29e539e44f46b7eb5ab6c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1644/agentshield_0.2.1644_linux_arm64.tar.gz"
      sha256 "97ed74953c6dad640ec620fb6d4b15ae92ad8150a83678225e44003fe7f825ac"
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
