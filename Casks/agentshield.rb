cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2465"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2465/agentshield_0.2.2465_darwin_amd64.tar.gz"
      sha256 "b13a2b6c5ec271960ebd4e40b33b0155eca39f07f6270368931f96c11c7bdde8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2465/agentshield_0.2.2465_darwin_arm64.tar.gz"
      sha256 "589926bbe36e4ed49a32135e36380d8a3e868631d25974a530c373cb34423d44"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2465/agentshield_0.2.2465_linux_amd64.tar.gz"
      sha256 "a2f0b062a7cc5ad118c8899eef3007bf51d0489f499309c9eac3532ca60d2204"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2465/agentshield_0.2.2465_linux_arm64.tar.gz"
      sha256 "6401486108cfd3627ecab2f276ed0e41cba48c3be6e35e52b80b2184e6cceb4e"
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
