cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2401"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2401/agentshield_0.2.2401_darwin_amd64.tar.gz"
      sha256 "19e0f5943cc5d931a5470578cfac9d361f5ab6d99d75bc150c266c08d5d5922b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2401/agentshield_0.2.2401_darwin_arm64.tar.gz"
      sha256 "485e35cc83b4502ccabaaafcbc406a763df452ca9748c497b3bb5d16dc812e72"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2401/agentshield_0.2.2401_linux_amd64.tar.gz"
      sha256 "9a249388aad56008b5ebfaf82973700e5ce901653d39cae422d700ab39b9feeb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2401/agentshield_0.2.2401_linux_arm64.tar.gz"
      sha256 "1dbde8f44c8c43fa988190d2f8f495b3aef37101a90434f4b26911917e01847d"
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
