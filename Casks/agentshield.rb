cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1304"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1304/agentshield_0.2.1304_darwin_amd64.tar.gz"
      sha256 "15cfdb3f0407e0ba2bc7b7367f211f25f280eb10b31e8fe36465b2af48d0e0ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1304/agentshield_0.2.1304_darwin_arm64.tar.gz"
      sha256 "1a2d673ae8fb6280dcca0105b8e797756fab45a6703061fa21ce5d45df84078a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1304/agentshield_0.2.1304_linux_amd64.tar.gz"
      sha256 "75d40099c7894165377b8e493dd8302215423d85a84384d99691ca68ed5553fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1304/agentshield_0.2.1304_linux_arm64.tar.gz"
      sha256 "07a0474fa27ca8aed4a1d678357bd48dc9005ff024bdbf42963eaa0c235e93db"
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
