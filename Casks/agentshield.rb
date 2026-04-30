cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.827"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.827/agentshield_0.2.827_darwin_amd64.tar.gz"
      sha256 "a0ca9e5d4f89662b2affa66223ca01ccac5e898fe2b77db27fd7ecc49667126b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.827/agentshield_0.2.827_darwin_arm64.tar.gz"
      sha256 "6dbe3326f31eb21c6839c451fd43f6b8f96ac50aad2caedde9b3a48b7f45724b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.827/agentshield_0.2.827_linux_amd64.tar.gz"
      sha256 "433fcf8cef05f40570f1ad266af8e3d8b9e86d7aeac1dc737308985a6624b318"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.827/agentshield_0.2.827_linux_arm64.tar.gz"
      sha256 "a5f2945fd33804bbd8d8611d2d786b6f73d331f4b0d8dff0192f65eb2b8d7a8b"
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
