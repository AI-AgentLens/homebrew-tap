cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1518"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1518/agentshield_0.2.1518_darwin_amd64.tar.gz"
      sha256 "966656b13f2550c5c96ef96147fe52450f8df8a8fef87b4047ca5ec2e102d20c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1518/agentshield_0.2.1518_darwin_arm64.tar.gz"
      sha256 "022d8cd39b9645e9b1ec2d2d3c6bdb51a42acf2799d46bc58113b2f4bfd66e9b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1518/agentshield_0.2.1518_linux_amd64.tar.gz"
      sha256 "ea1485cd4f046d14c542f1943409173ec10a1c5fae57ce508ffa07e750e932d8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1518/agentshield_0.2.1518_linux_arm64.tar.gz"
      sha256 "0490756129f897cd6dc09f1d209a500e64bfa6636b78f67dd70dd048d081aaa8"
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
