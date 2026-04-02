cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.320"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.320/agentshield_0.2.320_darwin_amd64.tar.gz"
      sha256 "4b974dd47f8499086b6bb2ed63d0ec9b37cf7d36118caa16bb24441e351024ff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.320/agentshield_0.2.320_darwin_arm64.tar.gz"
      sha256 "492902990cc8cfe6418a0f9f6c955d1c6c95a11e5b338a4516fbb4faafba86f6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.320/agentshield_0.2.320_linux_amd64.tar.gz"
      sha256 "69005c29a0282dcf18c59e12c47c57731160891d7b6e80cef4bb9f1ddf3ccae1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.320/agentshield_0.2.320_linux_arm64.tar.gz"
      sha256 "d317cffd1c7661c69b4c3f651780933a6e2abf5f5548e6cb2293899e322b2444"
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
