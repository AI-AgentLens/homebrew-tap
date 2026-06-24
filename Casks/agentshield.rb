cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1429"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1429/agentshield_0.2.1429_darwin_amd64.tar.gz"
      sha256 "309fe75db76c335ca4c182f043234f9f6c672f4107b21095c6fd41b5acd335a2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1429/agentshield_0.2.1429_darwin_arm64.tar.gz"
      sha256 "05c2f13f37b64e49a041571c64710d90615a47fcef0e653e60b7418dd7c30101"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1429/agentshield_0.2.1429_linux_amd64.tar.gz"
      sha256 "f98a46f85666ac89ce2fa75d49df868bdc7c64a76ad6128202b0b20c35ce5b77"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1429/agentshield_0.2.1429_linux_arm64.tar.gz"
      sha256 "320e307858db6a9285ac2febebde4f4a2c7692edccf64500de6b8cb6e01a43f1"
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
