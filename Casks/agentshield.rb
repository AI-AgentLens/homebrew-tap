cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1140"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1140/agentshield_0.2.1140_darwin_amd64.tar.gz"
      sha256 "1d0ee38462184dad72183170de4ac43f249edea5e9df1c607673ad8a573040fe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1140/agentshield_0.2.1140_darwin_arm64.tar.gz"
      sha256 "c174abb12403e9c2e8d8b46d4a3a69044721940cf9a22c0767bd9021b45b487b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1140/agentshield_0.2.1140_linux_amd64.tar.gz"
      sha256 "729aa5f4ab250fa9a9fa527f11372744d6bb2f77c322b7c18dd6c3b5353b99e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1140/agentshield_0.2.1140_linux_arm64.tar.gz"
      sha256 "0cef5f8adfe1e2c4a09d562fa435dfc0209f01ead8b08127530e913e2177b1e4"
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
